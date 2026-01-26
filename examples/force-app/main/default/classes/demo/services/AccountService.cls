/**
 * Example service that demonstrates constructor injection.
 *
 * This class is intentionally thin: it delegates data access to {@link IAccountRepository}.
 */
public class AccountService {
    private final IAccountRepository repository;

    public AccountService(IAccountRepository repository) {
        this.repository = repository;
    }

    /**
     * Retrieves an Account using the configured selector.
     *
     * @param accountId Account Id
     * @return Account record
     */
    public Account getAccount(Id accountId) {
        return repository.getById(accountId);
    }
}
