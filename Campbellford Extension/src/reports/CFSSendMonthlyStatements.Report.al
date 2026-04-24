report 54000 "CFS Send Monthly Statements"
{
    ApplicationArea = All;
    Caption = 'Send Monthly Statements';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.", "CFS Statement Delivery";
            trigger OnAfterGetRecord()

            begin
                if StmtDelivery = "CFS Statement Delivery"::Email then begin
                    if Customer."E-Mail" = '' then CurrReport.Skip();
                    Customer.CFSSendMonthlyStatementEmail(StartDate, EndDate);
                end else if StmtDelivery = "CFS Statement Delivery"::Print then begin
                    PrintMonthlyStatement();
                end;
            end;

            trigger OnPostDataItem()
            begin
                if StmtDelivery = "CFS Statement Delivery"::Print then begin
                    // Create ZIP file for download


                    DataCompression.SaveZipArchive(ZipTempBlob);
                    DataCompression.CloseZipArchive();

                    DownloadFromStream(ZipTempBlob.CreateInStream(), 'Download Customer Documents', '', '*.zip', ClientFileZip);
                end;
            end;

            trigger OnPreDataItem()
            begin
                ClientFileZip := 'MonthlyStatements.zip';
                DataCompression.CreateZipArchive();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(optStmtDelivery; StmtDelivery)
                    {
                        ApplicationArea = All;
                        Caption = 'Statement Delivery Method';
                        ToolTip = 'Specifies the method of delivery for the statements.';
                    }
                    field(dtStartDate; StartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'From Date';
                    }
                    field(dtEndDate; EndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'To Date';
                    }

                }
            }
        }
    }


    trigger OnInitReport()
    begin
        StartDate := CalcDate('<CM+1D-1M>', WorkDate());
        EndDate := CalcDate('<CM>', WorkDate());
    end;

    procedure SetStmtDelivery(DeliveryMethod: Enum "CFS Statement Delivery")
    begin
        StmtDelivery := DeliveryMethod;
    end;

    var
        StartDate, EndDate : Date;
        StmtDelivery: Enum "CFS Statement Delivery";
        ClientFileZip: Text;
        ZipFile: File;
        ZipTempBlob: Codeunit "Temp Blob";
        TempFilePath: Text;
        DataCompression: Codeunit "Data Compression";


    procedure PrintMonthlyStatement()
    var
        TempEmailItem: Record "Email Item" temporary;
        UserSetup: Record "User Setup";
        TempBlob, invoiceBlob, CrMemoBlob : Codeunit "Temp Blob";
        CustStatementReport: Report "Standard Statement";
        CFSSalesInvoice: Report "Standard Sales - Invoice";
        CFSSalesCreditMemo: Report "Standard Sales - Credit Memo";
        Cust: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCreditMemoHeader: Record "Sales Cr.Memo Header";
        FileManagement: Codeunit "File Management";
        outStreamFile, outInvoiceStr, outCreditMemoStr : OutStream;
        InStr, inInvoiceStr, inCreditMemoStr : InStream;
        StatementFile, InvoiceFile, CreditMemoFile : Text;

    begin

        //print Customer Statement
        clear(TempBlob);
        clear(CustStatementReport);
        clear(outStreamFile);
        clear(InStr);
        TempBlob.CreateOutStream(outStreamFile);
        Cust.SetRange("No.", Customer."No.");
        Cust.SetRange("Date Filter", StartDate, EndDate);
        CustStatementReport.SetTableView(Cust);
        CustStatementReport.UseRequestPage(false);
        CustStatementReport.InitializeRequest(true, true, true, true, true, true, '30D', 0, true, StartDate, EndDate);


        if CustStatementReport.SaveAs('', ReportFormat::Pdf, outStreamFile) then
            if TempBlob.Length() > 0 then begin
                TempBlob.CreateInStream(InStr);
                StatementFile := StrSubstNo('Statement-%1-%2.pdf', Customer."No.", Format(EndDate, 0, '<Month Text>-<Year4>'));
                DataCompression.AddEntry(InStr, StatementFile);
                // DownloadFromStream(InStr, 'Download Customer Statement', '', '*.pdf', StatementFile);
            end;

        // print Sales Invoices within date range
        clear(invoiceBlob);
        clear(CFSSalesInvoice);
        clear(outInvoiceStr);
        clear(inInvoiceStr);
        invoiceBlob.CreateOutStream(outInvoiceStr);
        SalesInvoiceHeader.SetRange("Bill-to Customer No.", Customer."No.");
        SalesInvoiceHeader.SetRange("Posting Date", StartDate, EndDate);
        CFSSalesInvoice.SetTableView(SalesInvoiceHeader);
        CFSSalesInvoice.UseRequestPage(false);
        if CFSSalesInvoice.SaveAs('', ReportFormat::Pdf, outInvoiceStr) then
            if invoiceBlob.Length() > 0 then begin
                invoiceBlob.CreateInStream(inInvoiceStr);
                InvoiceFile := StrSubstNo('Invoices-%1-%2.pdf', Customer."No.", Format(EndDate, 0, '<Month Text>-<Year4>'));
                DataCompression.AddEntry(inInvoiceStr, InvoiceFile);
                // DownloadFromStream(inInvoiceStr, 'Download Customer Invoices', '', '*.pdf', InvoiceFile);
            end;
        // print Sales Credit Memos within date range
        clear(CrMemoBlob);
        clear(CFSSalesCreditMemo);
        clear(outCreditMemoStr);
        clear(inCreditMemoStr);
        CrMemoBlob.CreateOutStream(outCreditMemoStr);
        SalesCreditMemoHeader.SetRange("Bill-to Customer No.", Customer."No.");
        SalesCreditMemoHeader.SetRange("Posting Date", StartDate, EndDate);
        CFSSalesCreditMemo.SetTableView(SalesCreditMemoHeader);
        CFSSalesCreditMemo.UseRequestPage(false);
        if CFSSalesCreditMemo.SaveAs('', ReportFormat::Pdf, outCreditMemoStr) then
            if CrMemoBlob.Length() > 0 then begin
                CrMemoBlob.CreateInStream(inCreditMemoStr);
                CreditMemoFile := StrSubstNo('CreditMemos-%1-%2.pdf', Customer."No.", Format(EndDate, 0, '<Month Text>-<Year4>'));
                DataCompression.AddEntry(inCreditMemoStr, CreditMemoFile);
                // DownloadFromStream(inCreditMemoStr, 'Download Customer Credit Memos', '', '*.pdf', CreditMemoFile);
            end;


    end;
}
