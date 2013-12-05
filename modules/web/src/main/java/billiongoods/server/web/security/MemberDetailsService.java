package billiongoods.server.web.security;

import billiongoods.core.Personality;
import billiongoods.core.account.Account;
import billiongoods.core.account.AccountLockManager;
import billiongoods.core.account.AccountManager;
import billiongoods.core.account.AccountRecoveryManager;
import billiongoods.core.security.PersonalityContext;
import billiongoods.server.services.settings.MemberSettings;
import billiongoods.server.services.settings.MemberSettingsManager;
import org.springframework.dao.DataAccessException;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.social.UserIdSource;
import org.springframework.social.security.SocialUserDetailsService;

/**
 * @author Sergey Klimenko (smklimenko@gmail.com)
 */
public class MemberDetailsService implements UserDetailsService, SocialUserDetailsService, UserIdSource {
	private AccountManager accountManager;
	private AccountLockManager accountLockManager;
	private MemberSettingsManager memberSettingsManager;
	private AccountRecoveryManager accountRecoveryManager;

	public MemberDetailsService() {
	}

	@Override
	public String getUserId() {
		final Personality principal = PersonalityContext.getPrincipal();
		if (principal == null) {
			return null;
		}
		return String.valueOf(principal.getId());
	}

	@Override
	public MemberDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		return createUserDetails(accountManager.findByEmail(username), username);
	}

	@Override
	public MemberDetails loadUserByUserId(String userId) throws UsernameNotFoundException, DataAccessException {
		return createUserDetails(accountManager.getAccount(Long.decode(userId)), userId);
	}

	public MemberDetails loadUserByAccount(Account account) throws UsernameNotFoundException, DataAccessException {
		return createUserDetails(account, null);
	}

	private MemberDetails createUserDetails(Account account, Object id) {
		if (account == null) {
			throw new UsernameNotFoundException("Account not found in the system: " + id);
		}
		final boolean locked = accountLockManager.isAccountLocked(account);
		final boolean expired = (accountRecoveryManager.getToken(account) != null);
		final MemberSettings settings = memberSettingsManager.getMemberSettings(account);

		return new MemberDetails(account, settings, locked, expired);
	}

	public void setAccountManager(AccountManager accountManager) {
		this.accountManager = accountManager;
	}

	public void setAccountLockManager(AccountLockManager accountLockManager) {
		this.accountLockManager = accountLockManager;
	}

	public void setMemberSettingsManager(MemberSettingsManager memberSettingsManager) {
		this.memberSettingsManager = memberSettingsManager;
	}

	public void setAccountRecoveryManager(AccountRecoveryManager accountRecoveryManager) {
		this.accountRecoveryManager = accountRecoveryManager;
	}
}
