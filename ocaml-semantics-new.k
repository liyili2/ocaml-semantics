requires "ocaml-syntax.k"
requires "ocaml-abstract-syntax.k"

module OCAML-SYNTAX-EXTRAS
    imports OCAML-SYNTAX
    imports OCAML-ABSTRACT-SYNTAX


syntax KResult ::= Int

    syntax KItem
      ::= "initEnv"
        | "binding"
        | "matching"
        | "assigning"
        | "debug"




endmodule


module OCAML-CONFIGURATION
    imports OCAML-SYNTAX
//    imports OCAML-TRANS
    imports OCAML-ABSTRACT-SYNTAX
    imports OCAML-SYNTAX-EXTRAS

    configuration
        <T>
            <k color="LightGreen"> $PGM:ModuleItemListFactor </k>
            <env color="LightSkyBlue"> .Map </env>
            <store color="LightSteelBlue"> .Map </store>
            <xstack color="LightSlateBlue"> .K </xstack>
            <nextLoc> 0 </nextLoc>
            <assign> .Map </assign>
            <records>
                <record multiplicity="*">
                    <recordId> 0 </recordId>
                    <fields> .Map </fields>
                </record>
            </records>
            <br/>
            <matchAnalysis multiplicity="?" color="LightGoldenrod">
                <matchK color="PaleGreen"> matching </matchK>
                <cases> .K </cases>
                <scrutinee> .K </scrutinee>
                <expr> .K </expr>
            </matchAnalysis>
            <br/>
            <patternAttempts>
                <patternAttempt multiplicity="*">
                    <patterns color="Violet"> .K </patterns>
                    <subst color="GreenYellow"> .Map </subst>
                </patternAttempt>
            </patternAttempts>
            <output> "" </output>
        </T>
        <result multiplicity="?" color="DodgerBlue">
            <exprResult> .K </exprResult>
            <outputInResult> "" </outputInResult>
        </result>


endmodule

module OCAML-INCLUDE
    imports OCAML-SYNTAX
    imports OCAML-ABSTRACT-SYNTAX
    imports OCAML-SYNTAX-EXTRAS
    imports OCAML-CONFIGURATION
//    imports OCAML-APPLICATION
//    imports OCAML-EXTERNAL

endmodule


module OCAML-SEMANTICS-NEW 
	imports OCAML-INCLUDE

rule <k> I1:Int + I2:Int => I1 +Int I2 </k>


endmodule


