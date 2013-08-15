package billiongoods.server.services.payment.impl;

import billiongoods.server.services.basket.BasketItem;
import billiongoods.server.services.payment.OrderItem;
import billiongoods.server.warehouse.ArticleDescription;
import billiongoods.server.warehouse.Property;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Collection;

/**
 * @author Sergey Klimenko (smklimenko@gmail.com)
 */
@Entity
@Table(name = "store_order_item")
public class HibernateOrderItem implements OrderItem {
    @EmbeddedId
    private Pk pk;

    @Column(name = "name")
    private String name;

    @Column(name = "article")
    private Integer article;

    @Column(name = "quantity")
    private int quantity;

    @Column(name = "amount")
    private double amount;

    @Column(name = "weight")
    private double weight;

    @Column(name = "options")
    private String options;

    @Deprecated
    HibernateOrderItem() {
    }

    public HibernateOrderItem(HibernateOrder order, BasketItem item, int number) {
        this.pk = new Pk(order.getId(), number);

        final ArticleDescription article = item.getArticle();

        this.name = article.getName();
        this.article = article.getId();
        this.quantity = item.getQuantity();
        this.amount = article.getPrice();
        this.weight = article.getWeight();

        StringBuilder sb = new StringBuilder();
        final Collection<Property> options1 = item.getOptions();
        if (options1 != null) {
            for (Property property : options1) {
                sb.append(property.getAttribute().getName()).append(": ").append(property.getValue());
                sb.append("; ");
            }
            if (sb.length() > 2) {
                sb.setLength(sb.length() - 2);
            }
        }
        this.options = sb.toString();
    }

    public Integer getNumber() {
        return pk.number;
    }

    @Override
    public Integer getArticle() {
        return article;
    }

    @Override
    public String getName() {
        return name;
    }

    @Override
    public int getQuantity() {
        return quantity;
    }

    @Override
    public double getAmount() {
        return amount;
    }

    @Override
    public double getWeight() {
        return weight;
    }

    @Override
    public String getOptions() {
        return options;
    }

    @Embeddable
    public static class Pk implements Serializable {
        @Column(name = "orderId")
        private Long orderId;

        @Column(name = "number")
        private Integer number;

        public Pk() {
        }

        public Pk(Long orderId, Integer number) {
            this.number = number;
            this.orderId = orderId;
        }
    }
}
