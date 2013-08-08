package billiongoods.server.test.state;

import billiongoods.core.Personality;

import java.util.Date;

/**
 * The player state manager allows check and track player's activity.
 *
 * @author Sergey Klimenko (smklimenko@gmail.com)
 */
public interface PlayerStateManager {
	void addPlayerStateListener(PlayerStateListener l);

	void removePlayerStateListener(PlayerStateListener l);

	/**
	 * Indicates is player online at this moment or not.
	 *
	 * @param personality the player to be checked.
	 * @return {@code true} if player is online; {@code false} - otherwise.
	 */
	boolean isPlayerOnline(Personality personality);

	/**
	 * Returns last player's activity date or null if there is no activity for the player or player unknown.
	 *
	 * @param personality the player to be checked.
	 * @return the last player's activity date or null if there is no activity for the player or player unknown.
	 */
	Date getLastActivityDate(Personality personality);
}
