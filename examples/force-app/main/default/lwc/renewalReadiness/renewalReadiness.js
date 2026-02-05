import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import load from '@salesforce/apex/RenewalReadinessController.load';
import save from '@salesforce/apex/RenewalReadinessController.save';

/**
 * LWC for viewing and editing renewal readiness line items.
 * Loads data from Apex, tracks local edits, and persists changes.
 */
export default class RenewalReadiness extends LightningElement {
    @api recordId;

    dto;
    errorMessage;
    isLoading = false;
    changesById = {};
    wiredResult;

    // Load the initial DTO and reset local error/changes on success.
    @wire(load, { opportunityId: '$recordId' })
    wiredDto(result) {
        this.wiredResult = result;
        if (result.data) {
            this.dto = this.cloneDto(result.data);
            this.errorMessage = null;
            this.changesById = {};
        } else if (result.error) {
            this.dto = null;
            this.errorMessage = this.reduceErrors(result.error);
        }
    }

    get hasLineItems() {
        return this.dto && this.dto.lineItems && this.dto.lineItems.length > 0;
    }

    // Update local DTO and change cache as inputs are edited.
    handleFieldChange(event) {
        const itemId = event.target.dataset.id;
        const field = event.target.dataset.field;
        if (!itemId || !field || !this.dto || !this.dto.lineItems) {
            return;
        }
        const value =
            event.target.type === 'checkbox'
                ? event.target.checked
                : event.target.value;

        const updatedItems = this.dto.lineItems.map((item) => {
            if (item.id !== itemId) {
                return item;
            }
            return { ...item, [field]: value };
        });
        this.dto = { ...this.dto, lineItems: updatedItems };

        const updatedItem = updatedItems.find((item) => item.id === itemId);
        if (updatedItem) {
            this.changesById = {
                ...this.changesById,
                [itemId]: {
                    id: updatedItem.id,
                    confirmed: updatedItem.confirmed,
                    riskFlag: updatedItem.riskFlag,
                    riskReason: updatedItem.riskReason
                }
            };
        }
    }

    // Persist only the edited line items back to Apex.
    async handleSave() {
        const changes = Object.values(this.changesById);
        if (!this.recordId) {
            this.showToast('Missing Opportunity', 'Record Id is required.', 'error');
            return;
        }
        if (changes.length === 0) {
            this.showToast('No Changes', 'Update a line item to save.', 'info');
            return;
        }

        this.isLoading = true;
        this.errorMessage = null;
        try {
            const result = await save({
                opportunityId: this.recordId,
                changes
            });
            this.dto = this.cloneDto(result);
            this.changesById = {};
            await refreshApex(this.wiredResult);
            this.showToast('Saved', 'Line items updated.', 'success');
        } catch (error) {
            this.errorMessage = this.reduceErrors(error);
            this.showToast('Save Failed', this.errorMessage, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    // Clone the DTO to avoid mutating the wire payload.
    cloneDto(dto) {
        if (!dto) {
            return null;
        }
        return {
            opportunityId: dto.opportunityId,
            score: dto.score,
            status: dto.status,
            lastCalculated: dto.lastCalculated,
            lineItems: dto.lineItems ? dto.lineItems.map((item) => ({ ...item })) : []
        };
    }

    // Normalize LDS/Apex error shapes into a single string.
    reduceErrors(errors) {
        const list = Array.isArray(errors) ? errors : [errors];
        return list
            .filter((error) => !!error)
            .map((error) => {
                if (Array.isArray(error.body)) {
                    return error.body.map((e) => e.message).join(', ');
                }
                if (error.body && typeof error.body.message === 'string') {
                    return error.body.message;
                }
                if (typeof error.message === 'string') {
                    return error.message;
                }
                return 'Unknown error';
            })
            .join(', ');
    }

    // Centralised toast helper for success/error/info messages.
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}
