package billiongoods.server.services.price.impl;

import billiongoods.core.search.Range;
import billiongoods.core.task.CleaningDayListener;
import billiongoods.server.services.price.*;
import billiongoods.server.warehouse.ArticleManager;
import billiongoods.server.warehouse.Price;
import billiongoods.server.warehouse.SupplierInfo;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.task.AsyncTaskExecutor;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.interceptor.DefaultTransactionAttribute;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.Future;

/**
 * @author Sergey Klimenko (smklimenko@gmail.com)
 */
public class HibernatePriceValidator implements PriceValidator, CleaningDayListener {
	private PriceLoader priceLoader;

	private SessionFactory sessionFactory;
	private ArticleManager articleManager;
	private ExchangeManager exchangeManager;

	private AsyncTaskExecutor taskExecutor;
	private PlatformTransactionManager transactionManager;

	private Future validationProgress;

	private static final int BULK_ARTICLES_SIZE = 100;

	private final Collection<PriceValidatorListener> listeners = new CopyOnWriteArrayList<>();

	private static final Logger log = LoggerFactory.getLogger("billiongoods.warehouse.PriceValidator");

	public HibernatePriceValidator() {
	}

	@Override
	public void addPriceValidatorListener(PriceValidatorListener l) {
		if (l != null) {
			listeners.add(l);
		}
	}

	@Override
	public void removePriceValidatorListener(PriceValidatorListener l) {
		if (l != null) {
			listeners.remove(l);
		}
	}

	private void doValidation() {
		try {
			final Date startedDate = new Date();
			final MarkupCalculator markupCalculator = exchangeManager.getMarkupCalculator();

			int count;
			TransactionStatus transaction = transactionManager.getTransaction(new DefaultTransactionAttribute(TransactionDefinition.PROPAGATION_REQUIRES_NEW));
			try {
				Session session = sessionFactory.getCurrentSession();
				final Query countQuery = session.createQuery("select count(*) from billiongoods.server.warehouse.impl.HibernateArticle a where a.active=true");

				count = ((Number) countQuery.uniqueResult()).intValue();
				transactionManager.commit(transaction);
			} catch (Exception ex) {
				transactionManager.rollback(transaction);
				throw ex;
			}

			for (PriceValidatorListener listener : listeners) {
				listener.priceValidationStarted(startedDate, count);
			}

			int index = 0;
			int processedCount = 0;
			final List<PriceRenewal> renewals = new ArrayList<>();
			while (true) {
				synchronized (this) {
					if (validationProgress == null) {
						log.info("Validation progress was interrupted");
						break;
					}
				}
				final Range range = Range.limit(index, BULK_ARTICLES_SIZE);

				transaction = transactionManager.getTransaction(new DefaultTransactionAttribute(TransactionDefinition.PROPAGATION_REQUIRES_NEW));
				try {
					Session session = sessionFactory.getCurrentSession();

					final Query query = session.createQuery("select a.id, a.price, a.supplierInfo from billiongoods.server.warehouse.impl.HibernateArticle a where a.active=true order by a.id");
					final List list = range.apply(query).list();
					if (list.isEmpty()) {
						transactionManager.commit(transaction);
						break;
					}
					for (Object o : list) {
						processedCount++;

						final Object[] a = (Object[]) o;

						final Integer articleId = (Integer) a[0];
						final SupplierInfo supplierInfo = (SupplierInfo) a[2];

						final Price oldPrice = (Price) a[1];
						final Price oldSupplierPrice = supplierInfo.getPrice();

						try {
							final Price newSupplierPrice = priceLoader.loadPrice(supplierInfo);
							final Price newPrice = markupCalculator.calculateMarkupPrice(newSupplierPrice);

							final HibernatePriceRenewal renewal = new HibernatePriceRenewal(articleId, new Date(), oldPrice, oldSupplierPrice, newPrice, newSupplierPrice);
							if (!newPrice.equals(oldPrice)) {
								log.info("Price for article has been updated: {}", renewal);
								renewals.add(renewal);

								articleManager.updatePrice(articleId, newPrice, newSupplierPrice);
								session.save(renewal);
							}

							for (PriceValidatorListener listener : listeners) {
								listener.priceValidated(articleId, renewal);
							}
						} catch (PriceLoadingException ex) {
							log.error("Price can't be loaded for article " + articleId, ex);
						}
					}
					session.flush();
					transactionManager.commit(transaction);
				} catch (Exception ex) {
					log.error("Bulk checks can't be processed for range: " + range, ex);
					transactionManager.rollback(transaction);
					break;
				}
				index += BULK_ARTICLES_SIZE;
			}

			final Date finishedDate = new Date();
			for (PriceValidatorListener listener : listeners) {
				listener.priceValidationFinished(finishedDate, processedCount, renewals);
			}
		} catch (Exception ex) {
			log.error("Price validation can't be done", ex);
		}

		synchronized (this) {
			validationProgress = null;
		}
	}

	@Override
	public void startPriceValidation() {
		synchronized (this) {
			if (isInProgress()) {
				return;
			}

			validationProgress = taskExecutor.submit(new Runnable() {
				@Override
				public void run() {
					doValidation();
				}
			});
		}
	}

	@Override
	public synchronized boolean isInProgress() {
		return validationProgress != null;
	}

	@Override
	public synchronized void stopPriceValidation() {
		validationProgress = null;
	}

	@Override
	public void cleanup(Date today) {
		startPriceValidation();
	}

	public void setTaskExecutor(AsyncTaskExecutor taskExecutor) {
		this.taskExecutor = taskExecutor;
	}

	public void setPriceLoader(PriceLoader priceLoader) {
		this.priceLoader = priceLoader;
	}

	public void setSessionFactory(SessionFactory sessionFactory) {
		this.sessionFactory = sessionFactory;
	}

	public void setArticleManager(ArticleManager articleManager) {
		this.articleManager = articleManager;
	}

	public void setExchangeManager(ExchangeManager exchangeManager) {
		this.exchangeManager = exchangeManager;
	}

	public void setTransactionManager(PlatformTransactionManager transactionManager) {
		this.transactionManager = transactionManager;
	}
}
