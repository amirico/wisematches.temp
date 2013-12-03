package billiongoods.server.web.servlet.mvc.account.form;

/**
 * @author Sergey Klimenko (smklimenko@gmail.com)
 */
public class SocialAssociationForm {
	private Long userId;
	private String email;
	private String action;

	public SocialAssociationForm() {
	}

	public Long getUserId() {
		return userId;
	}

	public void setUserId(Long userId) {
		this.userId = userId;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getAction() {
		return action;
	}

	public void setAction(String action) {
		this.action = action;
	}
}