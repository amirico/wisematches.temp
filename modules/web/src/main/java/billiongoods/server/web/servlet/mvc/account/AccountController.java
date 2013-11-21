package billiongoods.server.web.servlet.mvc.account;

import billiongoods.core.Visitor;
import billiongoods.core.account.*;
import billiongoods.server.services.ServerDescriptor;
import billiongoods.server.services.notify.NotificationException;
import billiongoods.server.services.notify.NotificationService;
import billiongoods.server.services.notify.Recipient;
import billiongoods.server.services.notify.Sender;
import billiongoods.server.web.servlet.mvc.AbstractController;
import billiongoods.server.web.servlet.mvc.account.form.AccountLoginForm;
import billiongoods.server.web.servlet.mvc.account.form.AccountRegistrationForm;
import billiongoods.server.web.servlet.sdo.ServiceResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.WebAttributes;
import org.springframework.social.connect.ConnectionFactory;
import org.springframework.social.connect.ConnectionFactoryLocator;
import org.springframework.social.connect.UsersConnectionRepository;
import org.springframework.social.connect.web.ConnectSupport;
import org.springframework.social.connect.web.ProviderSignInAttempt;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.Errors;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.support.SessionStatus;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.context.request.RequestAttributes;

import javax.validation.Valid;
import java.util.Locale;
import java.util.Set;

/**
 * @author Sergey Klimenko (smklimenko@gmail.com)
 */
@Controller
@RequestMapping("/account")
public class AccountController extends AbstractController {
	private ConnectSupport connectSupport;

	private AccountManager accountManager;
	private NotificationService notificationService;

	private ConnectionFactoryLocator connectionFactoryLocator;
	private UsersConnectionRepository usersConnectionRepository;

	private static final Logger log = LoggerFactory.getLogger("billiongoods.web.mvc.AccountSocialController");

	public AccountController() {
		super(true, false);
	}

	@RequestMapping(value = {"", "/", "/create"}, method = RequestMethod.GET)
	public String mainAccountPage() {
		return "redirect:/account/signin";
	}

	@RequestMapping("/signin")
	public String signinInternal(@ModelAttribute("login") AccountLoginForm login, BindingResult result,
								 @ModelAttribute("registration") AccountRegistrationForm register,
								 NativeWebRequest request) {
		restoreAccountLoginForm(login, request);

		final String error = login.getError();
		if (error != null) {
			switch (error) {
				case "credential":
					result.rejectValue("j_password", "account.signin.err.status.credential");
					break;
				case "status": {
					final AuthenticationException ex = (AuthenticationException) request.getAttribute(WebAttributes.AUTHENTICATION_EXCEPTION, RequestAttributes.SCOPE_SESSION);
					if (ex instanceof AccountStatusException) {
						if (ex instanceof LockedException) {
							result.rejectValue("j_password", "account.signin.err.status.locked");
						} else if (ex instanceof DisabledException) {
							result.rejectValue("j_password", "account.signin.err.status.disabled");
						} else if (ex instanceof CredentialsExpiredException) {
							result.rejectValue("j_password", "account.signin.err.status.credential");
						} else if (ex instanceof AccountExpiredException) {
							result.rejectValue("j_password", "account.signin.err.status.expired");
						}
					}
					break;
				}
				case "system": {
					final AuthenticationException ex = (AuthenticationException) request.getAttribute(WebAttributes.AUTHENTICATION_EXCEPTION, RequestAttributes.SCOPE_SESSION);
					log.error("Unknown authentication exception received for {}", login, ex);
					break;
				}
			}
		}
		return "/content/account/authorization";
	}

	@RequestMapping(value = "check")
	public ServiceResponse checkAvailability(@RequestParam("email") String email,
											 @RequestParam("nickname") String nickname,
											 Errors result, Locale locale) {
		log.debug("Check account validation for: {} ('{}')", email, nickname);

		final AccountAvailability a = accountManager.checkAccountAvailable(nickname, email);
		if (a.isAvailable()) {
			return responseFactory.success();
		} else {
			if (!a.isEmailAvailable()) {
				result.rejectValue("email", "account.register.email.err.busy");
			}
			if (!a.isUsernameProhibited()) {
				result.rejectValue("nickname", "account.register.nickname.err.incorrect");
			}
			return responseFactory.failure("account.register.err.busy", locale);
		}
	}

	@RequestMapping("/social/start")
	public String socialStart(NativeWebRequest request) {
		final String provider = request.getParameter("provider");
		if (!connectionFactoryLocator.registeredProviderIds().contains(provider)) {
			throw new IllegalStateException("Unsupported provider: " + provider);
		}
		final ConnectionFactory<?> connectionFactory = connectionFactoryLocator.getConnectionFactory(provider);
		if (connectionFactory == null) {
			throw new ProviderNotFoundException(provider);
		}
		return "redirect:" + connectSupport.buildOAuthUrl(connectionFactory, request);
	}

	@RequestMapping(value = "/social/association", method = RequestMethod.GET)
	public String socialAssociation(Model model, NativeWebRequest request) {
		final ProviderSignInAttempt attempt = (ProviderSignInAttempt) request.getAttribute(ProviderSignInAttempt.SESSION_ATTRIBUTE, RequestAttributes.SCOPE_SESSION);
		if (attempt == null) {
			return "redirect:/account/signin";
		}

		model.addAttribute("plain", Boolean.TRUE);
		model.addAttribute("connection", attempt.getConnection());

		return "/content/account/social/association";
	}

	@RequestMapping(value = "/social/association", method = RequestMethod.POST)
	public String socialAssociationAction(Model model, NativeWebRequest request) {
		final ProviderSignInAttempt attempt = (ProviderSignInAttempt) request.getAttribute(ProviderSignInAttempt.SESSION_ATTRIBUTE, RequestAttributes.SCOPE_SESSION);
		if (attempt == null) {
			return "redirect:/account/signin";
		}

		final AccountEditor editor = new AccountEditor();
//		editor.setEmail(atte);
//		editor.setUsername("");

//		accountManager.createAccount(new)

/*
		usersConnectionRepository.createConnectionRepository(userId).updateConnection(connection);
		attempt.getConnection()
		final ConnectionFactory<?> connectionFactory = connectionFactoryLocator.getConnectionFactory(providerId);
*/


		return "redirect:/"; // TODO: redirect to authorization
	}

	@RequestMapping(value = "create", method = RequestMethod.POST)
	@Transactional(propagation = Propagation.REQUIRES_NEW, isolation = Isolation.READ_UNCOMMITTED)
	public String createAccount(@ModelAttribute("login") AccountLoginForm login,
								@Valid @ModelAttribute("registration") AccountRegistrationForm form, BindingResult result,
								NativeWebRequest request, SessionStatus status, Locale locale) {
		log.info("Create new account request: {}", form);
		// Validate before next steps
		validateAccount(form, result, locale);

		Account account = null;
		if (!result.hasErrors()) {
			try {
				account = createAccount(form);
			} catch (DuplicateAccountException ex) {
				final Set<String> fieldNames = ex.getFieldNames();
				if (fieldNames.contains("email")) {
					result.rejectValue("email", "account.register.email.err.busy");
				}
				if (fieldNames.contains("nickname")) {
					result.rejectValue("nickname", "account.register.nickname.err.busy");
				}
			} catch (InadmissibleUsernameException ex) {
				result.rejectValue("nickname", "account.register.nickname.err.incorrect");
			} catch (Exception ex) {
				log.error("Account can't be created", ex);
				result.reject("billiongoods.error.internal");
			}
		}

		if (result.hasErrors() || account == null) {
			log.info("Account form is not correct: {}", result);
			return "/content/account/authorization";
		} else {
			log.info("Account has been created.");

			status.setComplete();
			try {
				notificationService.raiseNotification(Recipient.get(account), Sender.ACCOUNTS, "account.created", account, account.getUsername());
			} catch (NotificationException e) {
				log.error("Notification about new account can't be sent", e);
			}
			return forwardToAuthorization(request, account, form.isRememberMe());
		}
	}

	private String forwardToAuthorization(final NativeWebRequest request, final Account account, final boolean rememberMe) {
		request.setAttribute("rememberMe", rememberMe, RequestAttributes.SCOPE_REQUEST);
		request.setAttribute("PRE_AUTHENTICATED_ACCOUNT", account, RequestAttributes.SCOPE_REQUEST);
		return "forward:/account/authorization";
	}

	private void validateAccount(AccountRegistrationForm form, Errors errors, Locale locale) {
		if (!form.getPassword().equals(form.getConfirm())) {
			errors.rejectValue("confirm", "account.register.pwd-cfr.err.mismatch");
		}
		checkAvailability(form.getEmail(), form.getUsername(), errors, locale);
	}

	private Account createAccount(AccountRegistrationForm registration) throws AccountException {
		final AccountEditor editor = new AccountEditor();
		editor.setEmail(registration.getEmail());
		editor.setUsername(registration.getUsername());
		return accountManager.createAccount(editor.createAccount(), registration.getPassword());
	}

	@SuppressWarnings("deprecation")
	private void restoreAccountLoginForm(AccountLoginForm form, NativeWebRequest request) {
		if (form.getJ_username() == null) {
			final Authentication authentication;
			final AuthenticationException ex = (AuthenticationException) request.getAttribute(WebAttributes.AUTHENTICATION_EXCEPTION, RequestAttributes.SCOPE_SESSION);
			if (ex != null) {
				authentication = ex.getAuthentication();
			} else {
				authentication = SecurityContextHolder.getContext().getAuthentication();
			}
			if (authentication != null &&
					!(authentication instanceof AnonymousAuthenticationToken) &&
					!(authentication.getPrincipal() instanceof Visitor)) {
				form.setJ_username(authentication.getName());
			}
		}
	}

	@Autowired
	public void setAccountManager(AccountManager accountManager) {
		this.accountManager = accountManager;
	}

	@Autowired
	public void setServerDescriptor(final ServerDescriptor descriptor) {
		connectSupport = new ConnectSupport() {
			@Override
			protected String callbackUrl(NativeWebRequest request) {
				return descriptor.getWebHostName() + "/account/social/" + request.getParameter("provider");
			}
		};
		connectSupport.setUseAuthenticateUrl(true);
	}

	@Autowired
	public void setNotificationService(NotificationService notificationService) {
		this.notificationService = notificationService;
	}

	@Autowired
	public void setConnectionFactoryLocator(ConnectionFactoryLocator connectionFactoryLocator) {
		this.connectionFactoryLocator = connectionFactoryLocator;
	}

	@Autowired
	public void setUsersConnectionRepository(UsersConnectionRepository usersConnectionRepository) {
		this.usersConnectionRepository = usersConnectionRepository;
	}
}
