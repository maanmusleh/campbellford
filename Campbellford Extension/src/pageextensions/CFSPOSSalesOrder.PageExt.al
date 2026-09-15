pageextension 54005 "CFS POS Sales Order" extends "IWX POS Sales Order"
{


    layout
    {
        addfirst(factboxes)
        {
            part("CFS Customer Statistics FactBox"; "Customer Statistics FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Bill-to Customer No."),
                              "Date Filter" = field("Date Filter");
                Visible = false;
            }
            part("CFS Customer Details FactBox"; "Customer Details FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Bill-to Customer No."),
                              "Date Filter" = field("Date Filter");
            }
        }

        addafter(ppContactSalesHistorybyItemFactBox)
        {
            part("CFS Pending Approval FactBox"; "Pending Approval FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Table ID" = const(36),
                              "Document Type" = field("Document Type"),
                              "Document No." = field("No."),
                              Status = const(Open);
                Visible = bOpenApprovalEntriesExistForCurrUser;
            }
            part("CFS Approval FactBox"; "Approval FactBox")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }
    actions
    {
        addafter("F&unctions")
        {
            group("CFS Request Approval Action Group")
            {
                Caption = 'Request Approval';
                Image = SendApprovalRequest;
                action("CFS SendApprovalRequest")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = not bOpenApprovalEntriesExist and bCanRequestApprovalForFlow;
                    Image = SendApprovalRequest;
                    ToolTip = 'Request approval of the document.';

                    trigger OnAction()
                    begin
                        if cuApprovalsMgmt.CheckSalesApprovalPossible(Rec) then
                            cuApprovalsMgmt.OnSendSalesDocForApproval(Rec);
                    end;
                }
                action("CFS CancelApprovalRequest")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = bCanCancelApprovalForRecord or bCanCancelApprovalForFlow;
                    Image = CancelApprovalRequest;
                    ToolTip = 'Cancel the approval request.';

                    trigger OnAction()
                    begin
                        cuApprovalsMgmt.OnCancelSalesApprovalRequest(Rec);
                        cuWorkflowWebhookManagement.FindAndCancel(Rec.RecordId);
                    end;
                }
            }
        }

        addafter(aDimensions)
        {
            action("CFS Approvals")
            {
                AccessByPermission = TableData "Approval Entry" = R;
                ApplicationArea = Suite;
                Caption = 'Approvals';
                Image = Approvals;
                ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                trigger OnAction()
                begin
                    cuApprovalsMgmt.OpenApprovalsSales(Rec);
                end;
            }
        }

        addbefore(aComments)
        {
            group("CFS Approval Action Group")
            {
                Caption = 'Approval';
                action("CFS Approve")
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    ToolTip = 'Approve the requested changes.';
                    Visible = bOpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    begin
                        cuApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action("CFS Reject")
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    ToolTip = 'Reject the approval request.';
                    Visible = bOpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    begin
                        cuApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action("CFS Delegate")
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = bOpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    begin
                        cuApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action("CFS Approval Comment")
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    ToolTip = 'View or add comments for the record.';
                    Visible = bOpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    begin
                        cuApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
            }
        }

        addafter(aDimensions_Promoted)
        {
            actionref("CFS Approvals_Promoted"; "CFS Approvals")
            {
            }
        }

        addafter(grActionPromotedOrder)
        {
            group("CFS Action Promoted Request Approvals")
            {
                Caption = 'Request Approval';

                actionref("CFS SendApprovalRequest_Promoted"; "CFS SendApprovalRequest")
                {
                }
                actionref("CFS CancelApprovalRequest_Promoted"; "CFS CancelApprovalRequest")
                {
                }
            }
            group("CFS Action Promoted Approvals")
            {
                Caption = 'Approvals';

                actionref("CFS Approve_Promoted"; "CFS Approve")
                {
                }
                actionref("CFS Reject_Promoted"; "CFS Reject")
                {
                }
                actionref("CFS Approval Comment_Promoted"; "CFS Approval Comment")
                {
                }
                actionref("CFS Delegate_Promoted"; "CFS Delegate")
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        IWCSCFS_SetApprovalControlVisibility();
    end;

    trigger OnAfterGetRecord()
    begin
        IWCSCFS_SetApprovalControlVisibility();
    end;

    /// <summary>
    /// Function to set visibility for approval controls.
    /// </summary>
    local procedure IWCSCFS_SetApprovalControlVisibility()
    begin
        bOpenApprovalEntriesExistForCurrUser := cuApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        bOpenApprovalEntriesExist := cuApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        bCanCancelApprovalForRecord := cuApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        cuWorkflowWebhookManagement.GetCanRequestAndCanCancel(Rec.RecordId, bCanRequestApprovalForFlow, bCanCancelApprovalForFlow);
    end;

    var
        cuApprovalsMgmt: Codeunit "Approvals Mgmt.";
        cuWorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
        bOpenApprovalEntriesExistForCurrUser: Boolean;
        bOpenApprovalEntriesExist: Boolean;
        bCanCancelApprovalForRecord: Boolean;
        bCanCancelApprovalForFlow: Boolean;
        bCanRequestApprovalForFlow: Boolean;


}
