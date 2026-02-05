import { createElement } from 'lwc';
import RenewalReadiness from 'c/renewalReadiness';
import load from '@salesforce/apex/RenewalReadinessController.load';
import save from '@salesforce/apex/RenewalReadinessController.save';
import { refreshApex } from '@salesforce/apex';

// Wire adapter for the load Apex method (new API).
jest.mock(
    '@salesforce/apex/RenewalReadinessController.load',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return { default: createApexTestWireAdapter(jest.fn()) };
    },
    { virtual: true }
);

// Apex save mock (imperative call).
jest.mock(
    '@salesforce/apex/RenewalReadinessController.save',
    () => {
        return { default: jest.fn() };
    },
    { virtual: true }
);

// refreshApex mock to verify post-save refresh.
jest.mock(
    '@salesforce/apex',
    () => {
        return { refreshApex: jest.fn() };
    },
    { virtual: true }
);

// Wire adapter handle for emitting data/errors.
const loadAdapter = load;

// Base DTO fixture for UI rendering and save payloads.
const mockDto = {
    opportunityId: '006xx0000000001AAA',
    score: 78,
    status: 'On Track',
    lastCalculated: '2025-01-01T00:00:00.000Z',
    lineItems: [
        {
            id: 'a1',
            quantity: 2,
            totalPrice: 100,
            confirmed: false,
            riskFlag: false,
            riskReason: ''
        }
    ]
};

// Fixture with two line items to validate multi-row edits.
const mockDtoWithTwoItems = {
    ...mockDto,
    lineItems: [
        ...mockDto.lineItems,
        {
            id: 'a2',
            quantity: 1,
            totalPrice: 250,
            confirmed: true,
            riskFlag: true,
            riskReason: 'Budget'
        }
    ]
};

// Microtask drain helper for LWC async updates.
const flushPromises = () => new Promise((resolve) => setTimeout(resolve, 0));

describe('c-renewal-readiness', () => {
    // Reset DOM and mocks after each test to avoid cross-test leakage.
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders dto details and line items', async () => {
        const element = createElement('c-renewal-readiness', {
            is: RenewalReadiness
        });
        element.recordId = mockDto.opportunityId;
        document.body.appendChild(element);

        loadAdapter.emit(mockDto);
        await flushPromises();

        const content = element.shadowRoot.textContent;
        expect(content).toContain('Renewal Readiness');
        expect(content).toContain('Score');
        expect(content).toContain('78');
        expect(content).toContain('Status');
        expect(content).toContain('On Track');
        expect(content).toContain('Qty');
        expect(content).toContain('Total Price');

        const inputs = element.shadowRoot.querySelectorAll('lightning-input');
        expect(inputs).toHaveLength(3);
        expect(element.shadowRoot.querySelector('lightning-button')).not.toBeNull();
    });

    it('renders formatted values and hides save button without dto', async () => {
        const emptyElement = createElement('c-renewal-readiness', {
            is: RenewalReadiness
        });
        document.body.appendChild(emptyElement);
        expect(emptyElement.shadowRoot.querySelector('lightning-button')).toBeNull();

        const element = createElement('c-renewal-readiness', {
            is: RenewalReadiness
        });
        element.recordId = mockDto.opportunityId;
        document.body.appendChild(element);

        loadAdapter.emit(mockDto);
        await flushPromises();

        expect(
            element.shadowRoot.querySelector('lightning-formatted-date-time')
        ).not.toBeNull();
        expect(
            element.shadowRoot.querySelector('lightning-formatted-number')
        ).not.toBeNull();
    });

    it('shows empty state when no line items exist', async () => {
        const element = createElement('c-renewal-readiness', {
            is: RenewalReadiness
        });
        element.recordId = mockDto.opportunityId;
        document.body.appendChild(element);

        loadAdapter.emit({ ...mockDto, lineItems: [] });
        await flushPromises();

        expect(element.shadowRoot.textContent).toContain('No line items available.');
    });

    it('shows loading spinner during save', async () => {
        const element = createElement('c-renewal-readiness', {
            is: RenewalReadiness
        });
        element.recordId = mockDto.opportunityId;
        document.body.appendChild(element);

        loadAdapter.emit(mockDto);
        await flushPromises();

        const confirmedInput = element.shadowRoot.querySelector(
            'lightning-input[data-field="confirmed"]'
        );
        confirmedInput.checked = true;
        confirmedInput.dispatchEvent(new CustomEvent('change'));

        let resolveSave;
        save.mockReturnValue(
            new Promise((resolve) => {
                resolveSave = resolve;
            })
        );

        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();
        await flushPromises();

        expect(element.shadowRoot.querySelector('lightning-spinner')).not.toBeNull();

        resolveSave({ ...mockDto });
        await flushPromises();
        await flushPromises();
    });

    it('tracks changes for multiple fields and items', async () => {
        const element = createElement('c-renewal-readiness', {
            is: RenewalReadiness
        });
        element.recordId = mockDto.opportunityId;
        document.body.appendChild(element);

        loadAdapter.emit(mockDtoWithTwoItems);
        await flushPromises();

        const confirmedInput = element.shadowRoot.querySelector(
            'lightning-input[data-field="confirmed"]'
        );
        confirmedInput.checked = true;
        confirmedInput.dispatchEvent(new CustomEvent('change'));

        const riskFlagInput = element.shadowRoot.querySelector(
            'lightning-input[data-field="riskFlag"]'
        );
        riskFlagInput.checked = true;
        riskFlagInput.dispatchEvent(new CustomEvent('change'));

        const secondRiskReasonInput = element.shadowRoot.querySelector(
            'lightning-input[data-id="a2"][data-field="riskReason"]'
        );
        secondRiskReasonInput.value = 'Updated reason';
        secondRiskReasonInput.dispatchEvent(new CustomEvent('change'));

        save.mockResolvedValue({ ...mockDtoWithTwoItems });

        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();
        await flushPromises();
        await flushPromises();

        expect(save).toHaveBeenCalledWith({
            opportunityId: mockDto.opportunityId,
            changes: expect.arrayContaining([
                {
                    id: 'a1',
                    confirmed: true,
                    riskFlag: true,
                    riskReason: ''
                },
                {
                    id: 'a2',
                    confirmed: true,
                    riskFlag: true,
                    riskReason: 'Updated reason'
                }
            ])
        });
    });

    it('saves updated line items and shows success toast', async () => {
        const element = createElement('c-renewal-readiness', {
            is: RenewalReadiness
        });
        element.recordId = mockDto.opportunityId;
        document.body.appendChild(element);

        loadAdapter.emit(mockDto);
        await flushPromises();

        const toastHandler = jest.fn();
        element.addEventListener('lightning__showtoast', toastHandler);

        const confirmedInput = element.shadowRoot.querySelector(
            'lightning-input[data-field="confirmed"]'
        );
        confirmedInput.checked = true;
        confirmedInput.dispatchEvent(new CustomEvent('change'));

        const riskReasonInput = element.shadowRoot.querySelector(
            'lightning-input[data-field="riskReason"]'
        );
        riskReasonInput.value = 'Needs review';
        riskReasonInput.dispatchEvent(new CustomEvent('change'));

        save.mockResolvedValue({ ...mockDto });

        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();

        await flushPromises();
        await flushPromises();

        expect(save).toHaveBeenCalledWith({
            opportunityId: mockDto.opportunityId,
            changes: [
                {
                    id: 'a1',
                    confirmed: true,
                    riskFlag: false,
                    riskReason: 'Needs review'
                }
            ]
        });
        expect(refreshApex).toHaveBeenCalled();
        expect(toastHandler).toHaveBeenCalled();
        expect(toastHandler.mock.calls[0][0].detail.variant).toBe('success');
    });

    it('shows info toast when there are no changes', async () => {
        const element = createElement('c-renewal-readiness', {
            is: RenewalReadiness
        });
        element.recordId = mockDto.opportunityId;
        document.body.appendChild(element);

        loadAdapter.emit(mockDto);
        await flushPromises();

        const toastHandler = jest.fn();
        element.addEventListener('lightning__showtoast', toastHandler);

        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();
        await flushPromises();

        expect(save).not.toHaveBeenCalled();
        expect(toastHandler).toHaveBeenCalled();
        expect(toastHandler.mock.calls[0][0].detail.variant).toBe('info');
    });

    it('clears changes after save and shows no-changes toast', async () => {
        const element = createElement('c-renewal-readiness', {
            is: RenewalReadiness
        });
        element.recordId = mockDto.opportunityId;
        document.body.appendChild(element);

        loadAdapter.emit(mockDto);
        await flushPromises();

        const confirmedInput = element.shadowRoot.querySelector(
            'lightning-input[data-field="confirmed"]'
        );
        confirmedInput.checked = true;
        confirmedInput.dispatchEvent(new CustomEvent('change'));

        let resolveSave;
        save.mockReturnValue(
            new Promise((resolve) => {
                resolveSave = resolve;
            })
        );

        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();
        await flushPromises();

        resolveSave({ ...mockDto });
        await flushPromises();
        await flushPromises();

        const toastHandler = jest.fn();
        element.addEventListener('lightning__showtoast', toastHandler);

        button.click();
        await flushPromises();

        expect(toastHandler).toHaveBeenCalled();
        expect(toastHandler.mock.calls[0][0].detail.variant).toBe('info');
    });

    it('blocks save when recordId is missing', async () => {
        const element = createElement('c-renewal-readiness', {
            is: RenewalReadiness
        });
        document.body.appendChild(element);
        loadAdapter.emit(mockDto);
        await flushPromises();

        const confirmedInput = element.shadowRoot.querySelector(
            'lightning-input[data-field="confirmed"]'
        );
        confirmedInput.checked = true;
        confirmedInput.dispatchEvent(new CustomEvent('change'));

        const toastHandler = jest.fn();
        element.addEventListener('lightning__showtoast', toastHandler);

        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();
        await flushPromises();

        expect(save).not.toHaveBeenCalled();
        expect(toastHandler).toHaveBeenCalled();
        expect(toastHandler.mock.calls[0][0].detail.title).toBe('Missing Opportunity');
    });

    it('shows error when save fails', async () => {
        const element = createElement('c-renewal-readiness', {
            is: RenewalReadiness
        });
        element.recordId = mockDto.opportunityId;
        document.body.appendChild(element);

        loadAdapter.emit(mockDto);
        await flushPromises();

        const confirmedInput = element.shadowRoot.querySelector(
            'lightning-input[data-field="confirmed"]'
        );
        confirmedInput.checked = true;
        confirmedInput.dispatchEvent(new CustomEvent('change'));

        const toastHandler = jest.fn();
        element.addEventListener('lightning__showtoast', toastHandler);

        save.mockRejectedValue({ body: { message: 'Save failed' } });
        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();
        await flushPromises();
        await flushPromises();

        const errorMessage = element.shadowRoot.querySelector('.slds-text-color_error');
        expect(errorMessage).not.toBeNull();
        expect(errorMessage.textContent).toContain('Save failed');
        expect(toastHandler).toHaveBeenCalled();
        expect(toastHandler.mock.calls[0][0].detail.variant).toBe('error');
        expect(element.shadowRoot.querySelector('lightning-spinner')).toBeNull();
    });

    it('renders error message when wire fails', async () => {
        const element = createElement('c-renewal-readiness', {
            is: RenewalReadiness
        });
        element.recordId = mockDto.opportunityId;
        document.body.appendChild(element);

        loadAdapter.error({ body: { message: 'Load failed' }, message: 'Load failed' });
        await flushPromises();

        const errorMessage = element.shadowRoot.querySelector('.slds-text-color_error');
        expect(errorMessage).not.toBeNull();
        expect(errorMessage.textContent).toContain('Load failed');
    });

    it('clears error message after successful wire data', async () => {
        const element = createElement('c-renewal-readiness', {
            is: RenewalReadiness
        });
        element.recordId = mockDto.opportunityId;
        document.body.appendChild(element);

        loadAdapter.error({ body: { message: 'Old error' }, message: 'Old error' });
        await flushPromises();

        expect(
            element.shadowRoot.querySelector('.slds-text-color_error')
        ).not.toBeNull();

        loadAdapter.emit(mockDto);
        await flushPromises();

        expect(
            element.shadowRoot.querySelector('.slds-text-color_error')
        ).toBeNull();
    });

    it('handles wire error and hides save button', async () => {
        const element = createElement('c-renewal-readiness', {
            is: RenewalReadiness
        });
        element.recordId = mockDto.opportunityId;
        document.body.appendChild(element);

        loadAdapter.emit(mockDto);
        await flushPromises();

        loadAdapter.error({ body: [{ message: 'Load failed' }], message: 'Load failed' });
        await flushPromises();

        const errorMessage = element.shadowRoot.querySelector('.slds-text-color_error');
        expect(errorMessage).not.toBeNull();
        expect(errorMessage.textContent).toContain('Load failed');
        expect(element.shadowRoot.querySelector('lightning-button')).toBeNull();
    });

    it('handles save returning null dto', async () => {
        const element = createElement('c-renewal-readiness', {
            is: RenewalReadiness
        });
        element.recordId = mockDto.opportunityId;
        document.body.appendChild(element);

        loadAdapter.emit(mockDto);
        await flushPromises();

        const confirmedInput = element.shadowRoot.querySelector(
            'lightning-input[data-field="confirmed"]'
        );
        confirmedInput.checked = true;
        confirmedInput.dispatchEvent(new CustomEvent('change'));

        save.mockResolvedValue(null);
        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();
        await flushPromises();
        await flushPromises();

        expect(element.shadowRoot.querySelector('lightning-button')).toBeNull();
    });

    it('reduces array body errors from save failures', async () => {
        const element = createElement('c-renewal-readiness', {
            is: RenewalReadiness
        });
        element.recordId = mockDto.opportunityId;
        document.body.appendChild(element);

        loadAdapter.emit(mockDto);
        await flushPromises();

        const confirmedInput = element.shadowRoot.querySelector(
            'lightning-input[data-field="confirmed"]'
        );
        confirmedInput.checked = true;
        confirmedInput.dispatchEvent(new CustomEvent('change'));

        save.mockRejectedValue({ body: [{ message: 'First' }, { message: 'Second' }] });
        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();
        await flushPromises();
        await flushPromises();

        const errorMessage = element.shadowRoot.querySelector('.slds-text-color_error');
        expect(errorMessage).not.toBeNull();
        expect(errorMessage.textContent).toContain('First');
        expect(errorMessage.textContent).toContain('Second');
    });

    it('reduces string and unknown errors from save failures', async () => {
        const element = createElement('c-renewal-readiness', {
            is: RenewalReadiness
        });
        element.recordId = mockDto.opportunityId;
        document.body.appendChild(element);

        loadAdapter.emit(mockDto);
        await flushPromises();

        const confirmedInput = element.shadowRoot.querySelector(
            'lightning-input[data-field="confirmed"]'
        );
        confirmedInput.checked = true;
        confirmedInput.dispatchEvent(new CustomEvent('change'));

        save.mockRejectedValue({ message: 'Top error' });
        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();
        await flushPromises();
        await flushPromises();

        let errorMessage = element.shadowRoot.querySelector('.slds-text-color_error');
        expect(errorMessage).not.toBeNull();
        expect(errorMessage.textContent).toContain('Top error');

        save.mockRejectedValue({});
        button.click();
        await flushPromises();
        await flushPromises();

        errorMessage = element.shadowRoot.querySelector('.slds-text-color_error');
        expect(errorMessage).not.toBeNull();
        expect(errorMessage.textContent).toContain('Unknown error');
    });
});
