enum 54000 "CFS Statement Delivery"
{
    Caption = 'Statement Delivery';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Email)
    {
        Caption = 'Email';
    }
    value(2; Print)
    {
        Caption = 'Print';
    }
}
