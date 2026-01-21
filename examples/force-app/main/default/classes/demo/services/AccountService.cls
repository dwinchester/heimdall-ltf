/**
 * Example service that demonstrates constructor injection.
 *
 * This class is intentionally thin: it delegates data access to {@link IAccountSelector}.
 */
public class AccountService {
    private final IAccountSelector selector;

    public AccountService(IAccountSelector selector) {
        this.selector = selector;
    }

    /**
     * Retrieves an Account using the configured selector.
     *
     * @param accountId Account Id
     * @return Account record
     */
    public Account getAccount(Id accountId) {
        return selector.getById(accountId);
    }
}
