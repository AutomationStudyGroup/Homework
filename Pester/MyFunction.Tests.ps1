Describe "Tests for MyFunction" {

    BeforeAll {
        # create your database connection
        # $database = ...
    }

    AfterAll {
        # close database connection
        # $database.Dispose()
    }

    BeforeEach {
        $testFilePath = Join-Path $testdrive "myTestFile.txt"
        Set-Content -Path $testFilePath -Value "hello"
    }

    AfterEach {
        # do your clean up here, but not needed here because $testdrive is automatically cleaned up
        # Remove-Item $testFilePath -Force
    }

    It "Output should be same as input: <variation>" -Skip:($IsMacOS) -TestCases @(
        @{ variation = "string"; testData = "hello"; expectedOutput = "hello" },
        @{ variation = "number"; testData = 1234; expectedOutput = 1234 }
    ) {
        param ($testData, $expectedOutput)
        ./MyFunction.ps1 -text $testData | Should -BeExactly $expectedOutput
    }

    It "If given numbers, should add them together: <variation>" -TestCases @(
        @{ variation = "positive"; a = 1; b = 2; expectedSum = 4 }, # first variation should fail
        @{ variation = "negative"; a = -1; b = -2; expectedSum = -3 }
    ) {
        param( $a, $b, $expectedSum )
        ./MyFunction.ps1 -numberOne $a -numberTwo $b | Should -Be $expectedSum
    }

    It "Showing how to skip a pending test" -Pending {
        "this doesn't get executed"
    }

    It "Throws an error" {
        $errorMessage = "oops"
        $myError = { ./MyFunction.ps1 -errorMessage $errorMessage -ErrorAction Stop } |
            Should -Throw -ErrorId "Microsoft.PowerShell.Commands.WriteErrorException,MyFunction.ps1" -PassThru
        $myError.Exception.Message | Should -BeExactly $errorMessage
    }

    It "Demo testdrive" {
        try
        {
            $content = Get-Content -Path $testFilePath
            ./MyFunction.ps1 -text $content | Should -BeExactly $content
        }
        finally
        {
            # cleanup
        }
    }
}
