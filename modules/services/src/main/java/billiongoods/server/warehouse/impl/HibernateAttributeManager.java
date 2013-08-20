package billiongoods.server.warehouse.impl;

import billiongoods.server.warehouse.Attribute;
import billiongoods.server.warehouse.AttributeManager;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

/**
 * @author Sergey Klimenko (smklimenko@gmail.com)
 */
public class HibernateAttributeManager implements AttributeManager, InitializingBean {
	private SessionFactory sessionFactory;
	private final Map<Integer, Attribute> attributeMap = new HashMap<>();

	public HibernateAttributeManager() {
	}

	public void invalidate() {
		attributeMap.clear();

		final Session session = sessionFactory.openSession();
		final Query query = session.createQuery("from billiongoods.server.warehouse.impl.HibernateAttribute");

		final List list = query.list();
		for (Object o : list) {
			final HibernateAttribute a = (HibernateAttribute) o;
			attributeMap.put(a.getId(), a);
			session.evict(a);
		}
	}

	@Override
	public void afterPropertiesSet() throws Exception {
		invalidate();
	}

	@Override
	public Attribute getAttribute(Integer id) {
		return attributeMap.get(id);
	}

	@Override
	public Collection<Attribute> getAttributes() {
		return attributeMap.values();
	}

	@Override
	public Collection<Attribute> getAttributes(String name) {
		final List<Attribute> res = new ArrayList<>();
		for (Attribute attribute : attributeMap.values()) {
			if (attribute.getName().equalsIgnoreCase(name)) {
				res.add(attribute);

			}
		}
		return res;
	}

	@Override
	@Transactional(propagation = Propagation.MANDATORY)
	public Attribute createAttribute(String name, String unit) {
		final Session session = sessionFactory.getCurrentSession();
		final HibernateAttribute a = new HibernateAttribute(name, unit);
		session.save(a);
		attributeMap.put(a.getId(), a);
		return a;
	}

	@Override
	public Attribute updateAttribute(Integer id, String name, String unit) {
		final Session session = sessionFactory.getCurrentSession();

		final HibernateAttribute ha = (HibernateAttribute) session.get(HibernateAttribute.class, id);
		if (ha == null) {
			throw new IllegalArgumentException("Unknown attribute: " + id);
		}

		ha.setName(name);
		ha.setUnit(unit);
		session.update(ha);
		attributeMap.put(ha.getId(), ha);
		return ha;
	}

	public void setSessionFactory(SessionFactory sessionFactory) {
		this.sessionFactory = sessionFactory;
	}
}
