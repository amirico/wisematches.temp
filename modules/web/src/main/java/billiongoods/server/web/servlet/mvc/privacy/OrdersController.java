package billiongoods.server.web.servlet.mvc.privacy;

import billiongoods.core.search.Orders;
import billiongoods.server.services.payment.Order;
import billiongoods.server.services.payment.OrderContext;
import billiongoods.server.services.payment.OrderManager;
import billiongoods.server.web.servlet.mvc.AbstractController;
import billiongoods.server.web.servlet.mvc.PageableForm;
import billiongoods.server.web.servlet.mvc.UnknownEntityException;
import billiongoods.server.web.servlet.mvc.privacy.form.OrderFilterForm;
import billiongoods.server.web.servlet.mvc.privacy.form.OrderStateUnion;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

/**
 * @author Sergey Klimenko (smklimenko@gmail.com)
 */
@Controller
@RequestMapping("/privacy")
public class OrdersController extends AbstractController {
	private OrderManager orderManager;

	private static final Orders ORDERS_SORTING = Orders.of(billiongoods.core.search.Order.desc("timestamp"));

	public OrdersController() {
	}

	@RequestMapping("/order")
	public String privacyOrders(@RequestParam("id") Long orderId, Model model) {
		final Order order = orderManager.getOrder(orderId);
		if (order == null) {
			throw new UnknownEntityException(orderId, "order");
		}

		if (!getPrincipal().getId().equals(order.getPersonId())) {
			throw new UnknownEntityException(orderId, "order");
		}
		model.addAttribute("order", order);
		return "/content/privacy/order";
	}

	@RequestMapping("/orders")
	public String privacyOrders(@ModelAttribute("filter") OrderFilterForm filter, @ModelAttribute("pageableForm") PageableForm pageableForm, Model model) {
		final OrderStateUnion state = OrderStateUnion.byCode(filter.getState());

		final OrderContext context = new OrderContext(getPrincipal(), state != null ? state.getOrderStates() : null);
		final int totalCount = orderManager.getTotalCount(context);
		pageableForm.initialize(totalCount, totalCount);

		final List<Order> orders = orderManager.searchEntities(context, null, pageableForm.getRange(), ORDERS_SORTING);

		model.addAttribute("orders", orders);
		return "/content/privacy/orders";
	}

	@Autowired
	public void setOrderManager(OrderManager orderManager) {
		this.orderManager = orderManager;
	}
}