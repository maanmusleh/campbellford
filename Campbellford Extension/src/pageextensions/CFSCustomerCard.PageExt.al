pageextension 54000 "CFS Customer Card" extends "Customer Card"
{
    layout
    {
        addbefore("Print Statements")
        {
            field("CFS Statement Delivery"; Rec."CFS Statement Delivery")
            {
                ApplicationArea = All;
                Visible = true;
                ToolTip = 'Specifies how the customer wants to receive their statements.';
            }
            field("CFS Statement Email"; Rec."CFS Statement Email")
            {
                ApplicationArea = All;
                Visible = true;
                ToolTip = 'The email address where the customer wants to receive their statements.';
            }

        }
    }
    actions
    {
        addlast(processing)
        {
            action(SendMonthlyStatement)
            {
                ApplicationArea = All;
                Caption = 'Send Monthly Statement';
                Image = Email;
                ToolTip = 'Send the monthly statement to the customer via delivery  method specified.';

                trigger OnAction()
                var
                    Customer: Record Customer;
                    SendMonthlyStmt: Report "CFS Send Monthly Statements";

                begin
                    Customer.Reset();
                    Customer.SetRange("No.", Rec."No.");
                    clear(SendMonthlyStmt);
                    SendMonthlyStmt.SetTableView(Customer);
                    SendMonthlyStmt.SetStmtDelivery(Rec."CFS Statement Delivery");
                    SendMonthlyStmt.RunModal();
                end;
            }
        }
    }
}
