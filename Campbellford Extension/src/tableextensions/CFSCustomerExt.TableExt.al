tableextension 54000 "CFS Customer Ext." extends Customer
{
    fields
    {
        field(54300; "CFS Statement Delivery"; Enum "CFS Statement Delivery")
        {
            Caption = 'Statement Delivery';

            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "CFS Statement Delivery" = "CFS Statement Delivery"::Email then
                    Rec.TestField("E-Mail");
            end;
        }
        field(54001; "CFS Statement Email"; Text[200])
        {
            Caption = 'Statement Email';
            FieldClass = FlowField;
            CalcFormula = lookup("Custom Report Selection"."Send To Email" where("Source Type" = const(18), "Source No." = field("No."), Usage = const("C.Statement")));
            Editable = false;
        }
    }

    procedure CFSSendMonthlyStatementEmail(FromDate: Date; ToDate: Date): Boolean
    var
        TempEmailItem: Record "Email Item" temporary;
        UserSetup: Record "User Setup";
        EmailScenario: Enum "Email Scenario";
        EmailAttachments: Record "Email Attachments" temporary;
        cduEmailMessage: Codeunit "Email Message";
        cduEmail: Codeunit Email;
        TempBlob, invoiceBlob, CrMemoBlob : Codeunit "Temp Blob";
        CustStatementReport: Report "Standard Statement";
        CFSSalesInvoice: Report "Standard Sales - Invoice";
        CFSSalesCreditMemo: Report "Standard Sales - Credit Memo";
        Customer: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCreditMemoHeader: Record "Sales Cr.Memo Header";
        outStreamFile, outInvoiceStr, outCreditMemoStr : OutStream;
        InStr, inInvoiceStr, inCreditMemoStr : InStream;
        Subject: Text;
        Body: Text;
        SubjectTxt: Label 'Your Monthly Statement: %1';
        StatementFile, InvoiceFile, CreditMemoFile : Text;
    begin
        Subject := StrSubstNo(SubjectTxt, Format(ToDate, 0, '<Month Text>-<Year4>'));
        Body := 'Please find attached your monthly statement.<br>' +
                'If you have any questions, please contact us.<br>' +
                'Thank you for your business!';
        cduEmailMessage.Create(Rec."E-Mail", Subject, Body);
        cduEmailMessage.SetBodyHTMLFormatted(true);

        //print Customer Statement
        clear(TempBlob);
        clear(CustStatementReport);
        clear(outStreamFile);
        clear(InStr);
        TempBlob.CreateOutStream(outStreamFile);
        Customer.SetRange("No.", Rec."No.");
        Customer.SetRange("Date Filter", FromDate, ToDate);
        CustStatementReport.SetTableView(Customer);
        CustStatementReport.UseRequestPage(false);
        CustStatementReport.InitializeRequest(false, false, true, false, false, false, '30D', 0, false, FromDate, ToDate);
        CustStatementReport.SaveAs('', ReportFormat::Pdf, outStreamFile);
        if TempBlob.Length() > 0 then begin
            TempBlob.CreateInStream(InStr);
            StatementFile := StrSubstNo('Statement-%1-%2.pdf', Rec."No.", Format(ToDate, 0, '<Month Text>-<Year4>'));
            cduEmailMessage.AddAttachment(StatementFile, 'PDF', InStr);
        end;

        // print Sales Invoices within date range
        clear(invoiceBlob);
        clear(CFSSalesInvoice);
        clear(outInvoiceStr);
        clear(inInvoiceStr);
        invoiceBlob.CreateOutStream(outInvoiceStr);
        SalesInvoiceHeader.SetRange("Bill-to Customer No.", Rec."No.");
        SalesInvoiceHeader.SetRange("Posting Date", FromDate, ToDate);
        CFSSalesInvoice.SetTableView(SalesInvoiceHeader);
        CFSSalesInvoice.UseRequestPage(false);
        if CFSSalesInvoice.SaveAs('', ReportFormat::Pdf, outInvoiceStr) then
            if invoiceBlob.Length() > 0 then begin
                invoiceBlob.CreateInStream(inInvoiceStr);
                InvoiceFile := StrSubstNo('Invoices-%1-%2.pdf', Rec."No.", Format(ToDate, 0, '<Month Text>-<Year4>'));
                cduEmailMessage.AddAttachment(InvoiceFile, 'PDF', inInvoiceStr);
            end;
        // print Sales Credit Memos within date range
        clear(CrMemoBlob);
        clear(CFSSalesCreditMemo);
        clear(outCreditMemoStr);
        clear(inCreditMemoStr);
        CrMemoBlob.CreateOutStream(outCreditMemoStr);
        SalesCreditMemoHeader.SetRange("Bill-to Customer No.", Rec."No.");
        SalesCreditMemoHeader.SetRange("Posting Date", FromDate, ToDate);
        CFSSalesCreditMemo.SetTableView(SalesCreditMemoHeader);
        CFSSalesCreditMemo.UseRequestPage(false);
        if CFSSalesCreditMemo.SaveAs('', ReportFormat::Pdf, outCreditMemoStr) then
            if CrMemoBlob.Length() > 0 then begin
                CrMemoBlob.CreateInStream(inCreditMemoStr);
                CreditMemoFile := StrSubstNo('CreditMemos-%1-%2.pdf', Rec."No.", Format(ToDate, 0, '<Month Text>-<Year4>'));
                cduEmailMessage.AddAttachment(CreditMemoFile, 'PDF', inCreditMemoStr);
            end;
        exit(cduEmail.Send(cduEmailMessage, EmailScenario::"Monthly Statement"));
    end;

    procedure CFSSendMonthlyStatementPrint(FromDate: Date; ToDate: Date): Boolean
    var
        TempEmailItem: Record "Email Item" temporary;
        UserSetup: Record "User Setup";
        TempBlob, invoiceBlob, CrMemoBlob : Codeunit "Temp Blob";
        CustStatementReport: Report "Standard Statement";
        CFSSalesInvoice: Report "Standard Sales - Invoice";
        CFSSalesCreditMemo: Report "Standard Sales - Credit Memo";
        Customer: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCreditMemoHeader: Record "Sales Cr.Memo Header";
        FileManagement: Codeunit "File Management";
        outStreamFile, outInvoiceStr, outCreditMemoStr : OutStream;
        InStr, inInvoiceStr, inCreditMemoStr : InStream;
        StatementFile, InvoiceFile, CreditMemoFile : Text;
        ClientFileZip: Text;
        ZipFile: File;
        ZipTempBlob: Codeunit "Temp Blob";
        TempFilePath: Text;
        DataCompression: Codeunit "Data Compression";
    begin
        ClientFileZip := StrSubstNo('%1-MonthlyStatements.zip', Rec."No.");

        DataCompression.CreateZipArchive();


        //print Customer Statement
        clear(TempBlob);
        clear(CustStatementReport);
        clear(outStreamFile);
        clear(InStr);
        TempBlob.CreateOutStream(outStreamFile);
        Customer.SetRange("No.", Rec."No.");
        Customer.SetRange("Date Filter", FromDate, ToDate);
        CustStatementReport.SetTableView(Customer);
        CustStatementReport.UseRequestPage(false);
        CustStatementReport.InitializeRequest(true, true, true, true, true, true, '30D', 0, true, FromDate, Todate);


        CustStatementReport.SaveAs('', ReportFormat::Pdf, outStreamFile);

        if TempBlob.Length() > 0 then begin
            TempBlob.CreateInStream(InStr);
            StatementFile := StrSubstNo('Statement-%1-%2.pdf', Rec."No.", Format(ToDate, 0, '<Month Text>-<Year4>'));
            DataCompression.AddEntry(InStr, StatementFile);
            // DownloadFromStream(InStr, 'Download Customer Statement', '', '*.pdf', StatementFile);
        end;

        // print Sales Invoices within date range
        clear(invoiceBlob);
        clear(CFSSalesInvoice);
        clear(outInvoiceStr);
        clear(inInvoiceStr);
        invoiceBlob.CreateOutStream(outInvoiceStr);
        SalesInvoiceHeader.SetRange("Bill-to Customer No.", Rec."No.");
        SalesInvoiceHeader.SetRange("Posting Date", FromDate, ToDate);
        CFSSalesInvoice.SetTableView(SalesInvoiceHeader);
        CFSSalesInvoice.UseRequestPage(false);
        if CFSSalesInvoice.SaveAs('', ReportFormat::Pdf, outInvoiceStr) then
            if invoiceBlob.Length() > 0 then begin
                invoiceBlob.CreateInStream(inInvoiceStr);
                InvoiceFile := StrSubstNo('Invoices-%1-%2.pdf', Rec."No.", Format(ToDate, 0, '<Month Text>-<Year4>'));
                DataCompression.AddEntry(inInvoiceStr, InvoiceFile);
                // DownloadFromStream(inInvoiceStr, 'Download Customer Invoices', '', '*.pdf', InvoiceFile);
            end;
        // print Sales Credit Memos within date range
        clear(CrMemoBlob);
        clear(CFSSalesCreditMemo);
        clear(outCreditMemoStr);
        clear(inCreditMemoStr);
        CrMemoBlob.CreateOutStream(outCreditMemoStr);
        SalesCreditMemoHeader.SetRange("Bill-to Customer No.", Rec."No.");
        SalesCreditMemoHeader.SetRange("Posting Date", FromDate, ToDate);
        CFSSalesCreditMemo.SetTableView(SalesCreditMemoHeader);
        CFSSalesCreditMemo.UseRequestPage(false);
        if CFSSalesCreditMemo.SaveAs('', ReportFormat::Pdf, outCreditMemoStr) then
            if CrMemoBlob.Length() > 0 then begin
                CrMemoBlob.CreateInStream(inCreditMemoStr);
                CreditMemoFile := StrSubstNo('CreditMemos-%1-%2.pdf', Rec."No.", Format(ToDate, 0, '<Month Text>-<Year4>'));
                DataCompression.AddEntry(inCreditMemoStr, CreditMemoFile);
                // DownloadFromStream(inCreditMemoStr, 'Download Customer Credit Memos', '', '*.pdf', CreditMemoFile);
            end;

        DataCompression.SaveZipArchive(ZipTempBlob);
        DataCompression.CloseZipArchive();

        DownloadFromStream(ZipTempBlob.CreateInStream(), 'Download Customer Documents', '', '*.zip', ClientFileZip);
        exit(true);
    end;
}
