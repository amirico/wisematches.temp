package billiongoods.server.web.servlet.mvc.maintain;

import billiongoods.server.warehouse.Attribute;
import billiongoods.server.warehouse.AttributeManager;
import billiongoods.server.web.servlet.mvc.AbstractController;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author Sergey Klimenko (smklimenko@gmail.com)
 */
@Controller
@RequestMapping("/maintain/attributes")
public class AttributeMaintainController extends AbstractController {
    private AttributeManager attributeManager;

    public AttributeMaintainController() {
    }

    @RequestMapping("view")
    public String viewAttributes(Model model) {
        model.addAttribute("attributes", attributeManager.searchEntities(null, null, null));
        return "/content/maintain/attrs";
    }


    @RequestMapping("add")
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public String addAttribute(@RequestParam("n") String name, @RequestParam("u") String unit, Model model) {
        final Attribute attribute = attributeManager.addAttribute(name, unit);
        model.addAttribute("attributes", attributeManager.searchEntities(null, null, null));
        return "redirect:/maintain/attributes/view";
    }

    @RequestMapping("remove")
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public String removeAttribute(@RequestParam("i") Integer id, Model model) {
        final Attribute attribute = attributeManager.getAttribute(id);
        if (attribute != null) {
            attributeManager.removeAttribute(attribute);
        }
        model.addAttribute("attributes", attributeManager.searchEntities(null, null, null));
        return "redirect:/maintain/attributes/view";
    }

    @Autowired
    public void setAttributeManager(AttributeManager attributeManager) {
        this.attributeManager = attributeManager;
    }
}
