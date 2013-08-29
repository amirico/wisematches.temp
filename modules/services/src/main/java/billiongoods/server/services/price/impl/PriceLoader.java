package billiongoods.server.services.price.impl;

import billiongoods.server.warehouse.Price;
import billiongoods.server.warehouse.SupplierInfo;

/**
 * @author Sergey Klimenko (smklimenko@gmail.com)
 */
public interface PriceLoader {
    void initialize();

    Price loadPrice(SupplierInfo supplierInfo) throws PriceLoadingException;
}
