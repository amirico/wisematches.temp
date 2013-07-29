package billiongoods.server.warehouse;

import java.util.Date;

/**
 * @author Sergey Klimenko (smklimenko@gmail.com)
 */
public interface ArticleDescription {
	Long getId();

	String getName();

	boolean isActive();


	Category getCategory();


	/**
	 * Returns current price. If there is any discount for the article this value contains discounted price.
	 *
	 * @return the current supplier's price.
	 */
	float getPrice();

	/**
	 * Returns primordial price. This value can be used
	 * to get discount and is {@code null} if there is no discount. Returned value
	 * contains original, primordial price before discount.
	 *
	 * @return the primordial supplier's price or {@code null} if there is no any discount.
	 */
	Float getPrimordialPrice();


	/**
	 * Returns date when article will be available again or {@code null} if it's available right now.
	 *
	 * @return date when article will be available again or {@code null} if it's available right now.
	 */
	Date getRestockDate();

	/**
	 * Returns date when article was registered in the warehouse. Never null.
	 *
	 * @return the date when article was registered in the warehouse. Never null.
	 */
	Date getRegistrationDate();


	/**
	 * Returns preview image id.
	 */
	String getPreviewImageId();
}