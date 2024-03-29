package billiongoods.server.web.servlet.mvc.maintain.form;

import java.util.Arrays;

/**
 * @author Sergey Klimenko (smklimenko@gmail.com)
 */
public class ParcelForm {
	private Long orderId;
	private int number;
	private Integer[] items;

	public ParcelForm() {
	}

	public Long getOrderId() {
		return orderId;
	}

	public void setOrderId(Long orderId) {
		this.orderId = orderId;
	}

	public int getNumber() {
		return number;
	}

	public void setNumber(int number) {
		this.number = number;
	}

	public Integer[] getItems() {
		return items;
	}

	public void setItems(Integer[] items) {
		this.items = items;
	}

	@Override
	public String toString() {
		final StringBuilder sb = new StringBuilder("ParcelForm{");
		sb.append("orderId=").append(orderId);
		sb.append(", number=").append(number);
		sb.append(", items=").append(Arrays.toString(items));
		sb.append('}');
		return sb.toString();
	}
}
