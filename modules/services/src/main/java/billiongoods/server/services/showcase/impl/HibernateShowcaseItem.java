package billiongoods.server.services.showcase.impl;

import billiongoods.server.services.showcase.ShowcaseItem;

import javax.persistence.*;
import java.io.Serializable;

/**
 * @author Sergey Klimenko (smklimenko@gmail.com)
 */
@Entity
@Table(name = "store_showcase")
public class HibernateShowcaseItem implements ShowcaseItem, Comparable<HibernateShowcaseItem> {
	@EmbeddedId
	private Pk pk;

	@Column(name = "name")
	private String name;

	@Column(name = "category")
	private Integer category;

	@Column(name = "arrival")
	private boolean arrival;

	@Column(name = "subcategories")
	private boolean subCategories;

	@Deprecated
	HibernateShowcaseItem() {
	}

	public HibernateShowcaseItem(Integer section, Integer position, String name, Integer category, boolean arrival, boolean subCategories) {
		this.pk = new Pk(section, position);
		this.name = name;
		this.category = category;
		this.arrival = arrival;
		this.subCategories = subCategories;
	}

	@Override
	public String getName() {
		return name;
	}

	public Integer getSection() {
		return pk.section;
	}

	public Integer getPosition() {
		return pk.position;
	}

	@Override
	public Integer getCategory() {
		return category;
	}

	@Override
	public boolean isArrival() {
		return arrival;
	}

	@Override
	public boolean isSubCategories() {
		return subCategories;
	}

	public void setName(String name) {
		this.name = name;
	}

	public void setCategory(Integer category) {
		this.category = category;
	}

	public void setArrival(boolean arrival) {
		this.arrival = arrival;
	}

	public void setSubCategories(boolean subCategories) {
		this.subCategories = subCategories;
	}

	@Override
	public int compareTo(HibernateShowcaseItem o) {
		return pk.compareTo(o.pk);
	}

	@Embeddable
	public static class Pk implements Serializable, Comparable<Pk> {
		@Column(name = "section")
		private Integer section;

		@Column(name = "position")
		private Integer position;

		public Pk() {
		}

		public Pk(Integer section, Integer position) {
			this.section = section;
			this.position = position;
		}

		@Override
		public boolean equals(Object o) {
			if (this == o) return true;
			if (!(o instanceof Pk)) return false;

			Pk pk = (Pk) o;

			if (section != null ? !section.equals(pk.section) : pk.section != null) return false;
			if (position != null ? !position.equals(pk.position) : pk.position != null) return false;

			return true;
		}

		@Override
		public int hashCode() {
			int result = section != null ? section.hashCode() : 0;
			result = 31 * result + (position != null ? position.hashCode() : 0);
			return result;
		}

		@Override
		public int compareTo(Pk o) {
			int a = section.compareTo(o.section);
			if (a != 0) {
				return a;
			}
			return position.compareTo(o.position);
		}
	}
}
