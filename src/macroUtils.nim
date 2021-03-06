import macros
import std/with
import tables

## Utilites for use in macros

type
    ProcParameter* = object
        name*: string
        kind*: string
        help*: string

const
    optionPrefixes* = {'$', '%'} ## $ means variables, % means variable help

proc getDoc*(prc: NimNode): string =
    ## Gets the doc string for a procedure
    #expectKind(prc, nnkDo)
    echo prc.treeRepr
    let docString = prc
        .findChild(it.kind == nnkStmtList)
        .findChild(it.kind == nnkCommentStmt)
    if docString != nil:
        result = docString.strVal

proc getParameterDescription*(prc: NimNode, name: string): string =
    ## Gets the value of the help pragma that is attached to a parameter
    ## The pragma is attached to the parameter like so
    ## cmd.addChat("echo") do (times {.help: "The number of times to time"}) = discard
    #expectKind(prc, nnkDo)
    var pragma = findChild(prc, it.kind == nnkPragma and it[0][0].strVal == "help")
    if pragma != nil:
        result = pragma[0][1].strVal

proc getParameters*(prc: NimNode): seq[ProcParameter] =
    ## Gets the both the name, type, and help message of each parameter and returns it in a sequence
    #expectKind(prc, nnkDo)
    for node in prc:
        if node.kind == nnkFormalParams:
            for paramNode in node:
                if paramNode.kind == nnkIdentDefs:
                    var parameter: ProcParameter
                    # If the parameter has a pragma attached then a bit more work is needed to get the name of the parameter
                    if paramNode[0].kind == nnkPragmaExpr:
                       parameter.name = paramNode[0][0].strVal
                    else:
                        parameter.name = paramNode[0].strVal 
                    with parameter:
                        kind = $paramNode[1].toStrLit # toStrLit is used since it works better with types that are Option[T]
                        help = prc.getParameterDescription(parameter.name)
                    result.add parameter
export tables
