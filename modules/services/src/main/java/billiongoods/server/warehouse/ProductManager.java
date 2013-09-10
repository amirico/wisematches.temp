package billiongoods.server.warehouse;

import billiongoods.core.search.SearchManager;

/**
 * @author Sergey Klimenko (smklimenko@gmail.com)
 */
public interface ProductManager extends SearchManager<ProductDescription, ProductContext> {
	void addProductListener(ProductListener l);

	void removeProductListener(ProductListener l);

	Product getProduct(Integer id);

	Product getProduct(String sku);

	ProductDescription getDescription(Integer id);


	Product createProduct(ProductEditor editor);

	Product updateProduct(Integer id, ProductEditor editor);

	Product removeProduct(Integer id);


	void updateSold(Integer id, int quantity);

	void updatePrice(Integer id, Price price, Price supplierPrice);
}