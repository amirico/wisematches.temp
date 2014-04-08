package billiongoods.server.web.servlet.mvc.maintain;

import billiongoods.core.search.Orders;
import billiongoods.server.services.address.Address;
import billiongoods.server.services.payment.*;
import billiongoods.server.web.servlet.mvc.AbstractController;
import billiongoods.server.web.servlet.mvc.UnknownEntityException;
import billiongoods.server.web.servlet.mvc.maintain.form.OrderStateForm;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.validation.Errors;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import java.text.SimpleDateFormat;
import java.util.EnumSet;
import java.util.List;

/**
 * @author Sergey Klimenko (smklimenko@gmail.com)
 */
@Controller
@RequestMapping("/maintain/order")
public class OrderMaintainController extends AbstractController {
	private OrderManager orderManager;

	private static final SimpleDateFormat SIMPLE_DATE_FORMAT = new SimpleDateFormat("yyyy.MM.dd");
	private static final Orders TIMESTAMP = Orders.of(billiongoods.core.search.Order.desc("timestamp"));

	public OrderMaintainController() {
	}

	@RequestMapping(value = "")
	public String viewOrders(@RequestParam(value = "state", defaultValue = "ACCEPTED") String state, Model model) {
		final EnumSet<OrderState> orderState = EnumSet.of(OrderState.valueOf(state));

		final List<Order> orders = orderManager.searchEntities(new OrderContext(orderState), null, null, TIMESTAMP);
		model.addAttribute("orders", orders);
		model.addAttribute("orderState", orderState);

		model.addAttribute("ordersSummary", orderManager.getOrdersSummary());

		return "/content/maintain/orders";
	}

	@RequestMapping(value = "view")
	public String viewOrder(@RequestParam("id") String id, @RequestParam("type") String type, @ModelAttribute("form") OrderStateForm form, Model model) {
		Order order;
		if ("ref".equalsIgnoreCase(type)) {
			order = orderManager.getByReference(id);
		} else if ("token".equalsIgnoreCase(type)) {
			order = orderManager.getByToken(id);
		} else {
			order = orderManager.getOrder(Long.decode(id));
		}

		if (order == null) {
			throw new UnknownEntityException(id, "order");
		}

		form.setId(order.getId());
		form.setState(order.getOrderState());
		form.setCommentary(order.getCommentary());

		model.addAttribute("order", order);
		return "/content/maintain/order";
	}

	@Transactional(propagation = Propagation.REQUIRES_NEW)
	@RequestMapping(value = "promote", method = RequestMethod.POST)
	public String promoteOrder(@ModelAttribute("form") OrderStateForm form, Errors errors, Model model) {
		final Long id = form.getId();
		final String value = form.getValue();
		final String comment = form.getCommentary();
		final OrderState state = form.getState();

		if (id == null) {
			errors.rejectValue("value", "order.state.id.empty");
		}
		if (state == null) {
			errors.rejectValue("value", "order.state.state.empty");
		}

		if (state != null && !errors.hasErrors()) {
			switch (state) {
				case PROCESSING:
					orderManager.processing(id, value, comment);
					break;
				case SHIPPING:
					orderManager.shipping(id, value, comment);
					break;
				case SHIPPED:
					orderManager.shipped(id, value, comment);
					break;
				case SUSPENDED:
					try {
						orderManager.suspend(id, value != null && !value.isEmpty() ? SIMPLE_DATE_FORMAT.parse(value) : null, comment);
					} catch (Exception ex) {
						errors.rejectValue("value", "order.state.date.incorrect");
					}
					break;
				case CANCELLED:
					orderManager.cancel(id, value, comment);
					break;
				case CLOSED:
					try {
						orderManager.close(id, value != null && !value.isEmpty() ? SIMPLE_DATE_FORMAT.parse(value) : null, comment);
					} catch (Exception ex) {
						errors.rejectValue("value", "order.state.date.incorrect");
					}
					break;
				default:
					errors.rejectValue("value", "order.state.state.incorrect");
			}
		}

		if (!errors.hasErrors()) {
			return "redirect:/maintain/order/view?id=" + id + "&type=id";
		}

		model.addAttribute("order", orderManager.getOrder(id));
		return "/content/maintain/order";
	}


	@RequestMapping(value = "export")
	@Transactional(propagation = Propagation.REQUIRES_NEW)
	public HttpEntity<byte[]> promoteOrder(@ModelAttribute("order") Long orderId, Errors errors, Model model) {
		final Order o = orderManager.getOrder(orderId);
		if (o == null) {
			throw new UnknownEntityException(orderId, "o");
		}

		final StringBuilder b = new StringBuilder();
		b.append("Buyer Country," + "Buyer Fullname," + "Product SKU," + "Quantity," + "Buyer Address 1," + "Buyer Address 2," + "Buyer State," + "Buyer City," + "Buyer Zip," + "Buyer Phone Number," + "Remark," + "Sale Record Id");
		b.append(System.getProperty("line.separator"));

		int recordId = 1;
		final Shipment s = o.getShipment();
		final Address a = s.getAddress();
		for (OrderItem i : o.getOrderItems()) {
			b.append("\"RUSSIAN FEDERATION");
			b.append("\",\"");
			b.append(a.getFullName());
			b.append("\",\"");
			b.append(i.getProduct().getSupplierInfo().getReferenceCode());
			b.append("\",\"");
			b.append(i.getQuantity());
			b.append("\",\"");
			b.append(a.getLocation());
			b.append("\",\"");
			b.append(a.getRegion());
			b.append("\",\"");
			b.append(a.getCity());
			b.append("\",\"");
			b.append(a.getPostcode());
			b.append("\",\"");
			b.append("");
			b.append("\",\"");
			b.append("");
			b.append("\",\"");
			b.append(recordId++);
			b.append("\"");
			b.append(System.getProperty("line.separator"));
		}

		final byte[] bytes = b.toString().getBytes();

		final HttpHeaders header = new HttpHeaders();
		header.setContentType(new MediaType("application", "csv"));
		header.set("Content-Disposition", "attachment; filename=bgorder_" + orderId + ".csv");
		header.setContentLength(bytes.length);
		return new HttpEntity<>(bytes, header);
	}

	@Autowired
	public void setOrderManager(OrderManager orderManager) {
		this.orderManager = orderManager;
	}
}
