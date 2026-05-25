reportextension 54000 "CFS Standard Statement" extends "Standard Statement"
{
    dataset
    {
        add(Customer)
        {
            column(CFSCustAddress1; CustAddress[1]) { }
            column(CFSCustAddress2; CustAddress[2]) { }
            column(CFSCustAddress3; CustAddress[3]) { }
            column(CFSCustAddress4; CustAddress[4]) { }
            column(CFSCustAddress5; CustAddress[5]) { }
            column(CFSCustAddress6; CustAddress[6]) { }
            column(CFSCustAddress7; CustAddress[7]) { }
            column(CFSCustAddress8; CustAddress[8]) { }
        }
        modify(Customer)
        {
            trigger OnBeforePreDataItem()
            begin
                Customer.SetCurrentKey("Search Name");
                Customer.SetAscending("Search Name", true);
            end;

            trigger OnAfterAfterGetRecord()
            var
                i: integer;
                PrevText, CurrText : Text[100];
            begin
                FormatAdddress.Customer(CustAddress, Customer);
                PrevText := CustAddress[1];
                CustAddress[1] := StrSubStNo('Customer No.: %1', Customer."No.");
                For i := 2 to 8 do begin
                    CurrText := CustAddress[i];
                    CustAddress[i] := PrevText;
                    PrevText := CurrText;
                end;
            end;
        }
    }

    rendering
    {
        layout("CFS Customer Statement")
        {
            Type = Word;
            LayoutFile = './src/WordLayouts/CFS Customer Statement.docx';
        }
    }

    var
        FormatAdddress: Codeunit "Format Address";
        CustAddress: array[8] of Text[100];
}
