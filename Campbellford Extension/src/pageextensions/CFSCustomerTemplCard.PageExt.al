pageextension 54003 "CFS Customer Templ. Card" extends "Customer Templ. Card"
{
    layout
    {
        addafter("Document Sending Profile")
        {
            field("CFS Statement Delivery"; Rec."CFS Statement Delivery")
            {
                ApplicationArea = All;
            }
        }
    }
}
