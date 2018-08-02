[cmdletbinding()]
param(
    [parameter(ParameterSetName="text")]
    [string]$text,
    [parameter(ParameterSetName="number")]
    [int]$numberOne,
    [parameter(ParameterSetName="number")]
    [int]$numberTwo,
    [parameter(ParameterSetName="error")]
    [string]$errorMessage
)

process
{
    switch ($PSCmdlet.ParameterSetName)
    {
        "text" {
            $text
        }

        "number" {
            $numberOne + $numberTwo
        }

        "error" {
            Write-Error $errorMessage
        }
    }
}
