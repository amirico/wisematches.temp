package billiongoods.server.web.servlet.mvc.maintain;

import billiongoods.core.search.Orders;
import billiongoods.server.services.payment.Order;
import billiongoods.server.services.payment.OrderContext;
import billiongoods.server.services.payment.OrderManager;
import billiongoods.server.services.payment.OrderState;
import billiongoods.server.web.servlet.mvc.AbstractController;
import billiongoods.server.web.servlet.mvc.UnknownEntityException;
import billiongoods.server.web.servlet.mvc.maintain.form.OrderStateForm;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.validation.Errors;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

/**
 * @author Sergey Klimenko (smklimenko@gmail.com)
 */
@Controller
@RequestMapping("/maintain/order")
public class OrderMaintainController extends AbstractController {
	private OrderManager orderManager;

	private static final Logger log = LoggerFactory.getLogger("billiongoods.order.MaintainController");

	public OrderMaintainController() {
	}

	@RequestMapping(value = "")
	public String viewOrders(@RequestParam(value = "state", defaultValue = "ACCEPTED") String state, Model model) {
		final OrderState orderState = OrderState.valueOf(state);

		final List<Order> orders = orderManager.searchEntities(new OrderContext(orderState), Orders.of(billiongoods.core.search.Order.desc("timestamp")), null);
		model.addAttribute("orders", orders);
		model.addAttribute("orderState", orderState);

		return "/content/maintain/orders";
	}

	@RequestMapping(value = "view")
	public String viewOrder(@RequestParam("id") String id, @RequestParam("type") String type, Model model) {
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

		model.addAttribute("order", order);
		model.addAttribute("form", new OrderStateForm());
		return "/content/maintain/order";
	}

	@Transactional(propagation = Propagation.REQUIRES_NEW)
	@RequestMapping(value = "promote", method = RequestMethod.POST)
	public String promoteOrder(@ModelAttribute("form") OrderStateForm form, Errors errors, Model model) {
		final Long id = form.getId();
		final String value = form.getValue();
		final OrderState state = form.getState();

		if (id == null) {
			errors.rejectValue("value", "order.state.id.empty");
		}
		if (state == null) {
			errors.rejectValue("value", "order.state.state.empty");
		}
		if (value == null) {
			errors.rejectValue("value", "order.state.value.empty");
		}

		if (state != null && !errors.hasErrors()) {
			switch (state) {
				case PROCESSING:
					orderManager.processing(id, value);
					break;
				case SHIPPING:
					orderManager.shipping(id, value);
					break;
				case SHIPPED:
					orderManager.shipped(id, value);
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

	@Autowired
	public void setOrderManager(OrderManager orderManager) {
		this.orderManager = orderManager;
	}
}