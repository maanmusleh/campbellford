tableextension 54001 "CFS Customer Templ. ext" extends "Customer Templ."
{
    AllowInCustomizations = AsReadWrite;

    fields
    {
        field(54300; "CFS Statement Delivery"; Enum "CFS Statement Delivery")
        {
            Caption = 'Statement Delivery';

            DataClassification = ToBeClassified;
        }
    }
}
