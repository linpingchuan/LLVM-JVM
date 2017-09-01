{-# LANGUAGE UnicodeSyntax #-}
module VirtualMachine.Debug where
  import VirtualMachine.Types
  import Data.IORef
  import Data.Word
  import Data.Array.MArray
  import Control.Monad
  import Data.List
  import System.Console.ANSI
  import Text.Printf
  import Misc.Logger

  debugFrame :: StackFrame -> IO String
  debugFrame frame = readIORef frame >>= \f -> readIORef (operand_stack f)
    >>= \opstack -> mapM (readIORef >=> return . show) (local_variables f) >>= \localStr ->
    formatCodeSegment (code_segment f) >>= \csStr -> return $ "Stack_Frame{local_variables:[" ++ intercalate "," localStr
    ++ "],operand_stack:" ++ show opstack ++ ",code_segment:[" ++ csStr ++ "]}"
    where
      formatCodeSegment :: Code_Segment -> IO String
      formatCodeSegment cs = readIORef (program_counter cs) >>= \pc -> printCodeSegment 0 pc (byte_code cs)
        where
          printCodeSegment :: Word32 -> Word32 -> Instructions -> IO String
          printCodeSegment n m instr
            | n == (fromIntegral . length $ instr) = return ""
            | n == m && m < (fromIntegral . length $ instr) = setSGR [SetConsoleIntensity BoldIntensity] >> return ("⇛ " ++ printBC (instr !! fromIntegral n) ++ " ⇚,")
              >>= \str -> (++) str <$> (setSGR [SetConsoleIntensity NormalIntensity] >> printCodeSegment (n + 1) m instr)
            | otherwise = (++) (printBC (instr !! fromIntegral n) ++ ",") <$> printCodeSegment (n + 1) m instr

  -- Generated with Regular Expressions
  printBC :: ByteCode -> String
  printBC bc = case bc of
    00 -> "nop (0x00)"
    01 -> "aconst_null (0x01)"
    02 -> "iconst_m1 (0x02)"
    03 -> "iconst_0 (0x03)"
    04 -> "iconst_1 (0x04)"
    05 -> "iconst_2 (0x05)"
    06 -> "iconst_3 (0x06)"
    07 -> "iconst_4 (0x07)"
    08 -> "iconst_5 (0x08)"
    09 -> "lconst_0 (0x09)"
    10 -> "lconst_1 (0x0a)"
    11 -> "fconst_0 (0x0b)"
    12 -> "fconst_1 (0x0c)"
    13 -> "fconst_2 (0x0d)"
    14 -> "dconst_0 (0x0e)"
    15 -> "dconst_1 (0x0f)"
    16 -> "bipush (0x10)"
    17 -> "sipush (0x11)"
    18 -> "ldc (0x12)"
    19 -> "ldc_w (0x13)"
    20 -> "ldc2_w (0x14)"
    21 -> "iload (0x15)"
    22 -> "lload (0x16)"
    23 -> "fload (0x17)"
    24 -> "dload (0x18)"
    25 -> "aload (0x19)"
    26 -> "iload_0 (0x1a)"
    27 -> "iload_1 (0x1b)"
    28 -> "iload_2 (0x1c)"
    29 -> "iload_3 (0x1d)"
    30 -> "lload_0 (0x1e)"
    31 -> "lload_1 (0x1f)"
    32 -> "lload_2 (0x20)"
    33 -> "lload_3 (0x21)"
    34 -> "fload_0 (0x22)"
    35 -> "fload_1 (0x23)"
    36 -> "fload_2 (0x24)"
    37 -> "fload_3 (0x25)"
    38 -> "dload_0 (0x26)"
    39 -> "dload_1 (0x27)"
    40 -> "dload_2 (0x28)"
    41 -> "dload_3 (0x29)"
    42 -> "aload_0 (0x2a)"
    43 -> "aload_1 (0x2b)"
    44 -> "aload_2 (0x2c)"
    45 -> "aload_3 (0x2d)"
    46 -> "iaload (0x2e)"
    47 -> "laload (0x2f)"
    48 -> "faload (0x30)"
    49 -> "daload (0x31)"
    50 -> "aaload (0x32)"
    51 -> "baload (0x33)"
    52 -> "caload (0x34)"
    53 -> "saload (0x35)"
    54 -> "istore (0x36)"
    55 -> "lstore (0x37)"
    56 -> "fstore (0x38)"
    57 -> "dstore (0x39)"
    58 -> "astore (0x3a)"
    59 -> "istore_0 (0x3b)"
    60 -> "istore_1 (0x3c)"
    61 -> "istore_2 (0x3d)"
    62 -> "istore_3 (0x3e)"
    63 -> "lstore_0 (0x3f)"
    64 -> "lstore_1 (0x40)"
    65 -> "lstore_2 (0x41)"
    66 -> "lstore_3 (0x42)"
    67 -> "fstore_0 (0x43)"
    68 -> "fstore_1 (0x44)"
    69 -> "fstore_2 (0x45)"
    70 -> "fstore_3 (0x46)"
    71 -> "dstore_0 (0x47)"
    72 -> "dstore_1 (0x48)"
    73 -> "dstore_2 (0x49)"
    74 -> "dstore_3 (0x4a)"
    75 -> "astore_0 (0x4b)"
    76 -> "astore_1 (0x4c)"
    77 -> "astore_2 (0x4d)"
    78 -> "astore_3 (0x4e)"
    79 -> "iastore (0x4f)"
    80 -> "lastore (0x50)"
    81 -> "fastore (0x51)"
    82 -> "dastore (0x52)"
    83 -> "aastore (0x53)"
    84 -> "bastore (0x54)"
    85 -> "castore (0x55)"
    86 -> "sastore (0x56)"
    87 -> "pop (0x57)"
    88 -> "pop2 (0x58)"
    89 -> "dup (0x59)"
    90 -> "dup_x1 (0x5a)"
    91 -> "dup_x2 (0x5b)"
    92 -> "dup2 (0x5c)"
    93 -> "dup2_x1 (0x5d)"
    94 -> "dup2_x2 (0x5e)"
    95 -> "swap (0x5f)"
    96 -> "iadd (0x60)"
    97 -> "ladd (0x61)"
    98 -> "fadd (0x62)"
    99 -> "dadd (0x63)"
    100 -> "isub (0x64)"
    101 -> "lsub (0x65)"
    102 -> "fsub (0x66)"
    103 -> "dsub (0x67)"
    104 -> "imul (0x68)"
    105 -> "lmul (0x69)"
    106 -> "fmul (0x6a)"
    107 -> "dmul (0x6b)"
    108 -> "idiv (0x6c)"
    109 -> "ldiv (0x6d)"
    110 -> "fdiv (0x6e)"
    111 -> "ddiv (0x6f)"
    112 -> "irem (0x70)"
    113 -> "lrem (0x71)"
    114 -> "frem (0x72)"
    115 -> "drem (0x73)"
    116 -> "ineg (0x74)"
    117 -> "lneg (0x75)"
    118 -> "fneg (0x76)"
    119 -> "dneg (0x77)"
    120 -> "ishl (0x78)"
    121 -> "lshl (0x79)"
    122 -> "ishr (0x7a)"
    123 -> "lshr (0x7b)"
    124 -> "iushr (0x7c)"
    125 -> "lushr (0x7d)"
    126 -> "iand (0x7e)"
    127 -> "land (0x7f)"
    128 -> "ior (0x80)"
    129 -> "lor (0x81)"
    130 -> "ixor (0x82)"
    131 -> "lxor (0x83)"
    132 -> "iinc (0x84)"
    133 -> "i2l (0x85)"
    134 -> "i2f (0x86)"
    135 -> "i2d (0x87)"
    136 -> "l2i (0x88)"
    137 -> "l2f (0x89)"
    138 -> "l2d (0x8a)"
    139 -> "f2i (0x8b)"
    140 -> "f2l (0x8c)"
    141 -> "f2d (0x8d)"
    142 -> "d2i (0x8e)"
    143 -> "d2l (0x8f)"
    144 -> "d2f (0x90)"
    145 -> "i2b (0x91)"
    146 -> "i2c (0x92)"
    147 -> "i2s (0x93)"
    148 -> "lcmp (0x94)"
    149 -> "fcmpl (0x95)"
    150 -> "fcmpg (0x96)"
    151 -> "dcmpl (0x97)"
    152 -> "dcmpg (0x98)"
    153 -> "ifeq (0x99)"
    154 -> "ifne (0x9a)"
    155 -> "iflt (0x9b)"
    156 -> "ifge (0x9c)"
    157 -> "ifgt (0x9d)"
    158 -> "ifle (0x9e)"
    159 -> "if_icmpeq (0x9f)"
    160 -> "if_icmpne (0xa0)"
    161 -> "if_icmplt (0xa1)"
    162 -> "if_icmpge (0xa2)"
    163 -> "if_icmpgt (0xa3)"
    164 -> "if_icmple (0xa4)"
    165 -> "if_acmpeq (0xa5)"
    166 -> "if_acmpne (0xa6)"
    167 -> "goto (0xa7)"
    168 -> "jsr (0xa8)"
    169 -> "ret (0xa9)"
    170 -> "tableswitch (0xaa)"
    171 -> "lookupswitch (0xab)"
    172 -> "ireturn (0xac)"
    173 -> "lreturn (0xad)"
    174 -> "freturn (0xae)"
    175 -> "dreturn (0xaf)"
    176 -> "areturn (0xb0)"
    177 -> "return (0xb1)"
    178 -> "getstatic (0xb2)"
    179 -> "putstatic (0xb3)"
    180 -> "getfield (0xb4)"
    181 -> "putfield (0xb5)"
    182 -> "invokevirtual (0xb6)"
    183 -> "invokespecial (0xb7)"
    184 -> "invokestatic (0xb8)"
    185 -> "invokeinterface (0xb9)"
    186 -> "invokedynamic (0xba)"
    187 -> "new (0xbb)"
    188 -> "newarray (0xbc)"
    189 -> "anewarray (0xbd)"
    190 -> "arraylength (0xbe)"
    191 -> "athrow (0xbf)"
    192 -> "checkcast (0xc0)"
    193 -> "instanceof (0xc1)"
    194 -> "monitorenter (0xc2)"
    195 -> "monitorexit (0xc3)"
    196 -> "wide (0xc4)"
    197 -> "multianewarray (0xc5)"
    198 -> "ifnull (0xc6)"
    199 -> "ifnonnull (0xc7)"
    200 -> "goto_w (0xc8)"
    201 -> "jsr_w (0xc9)"
    202 -> "breakpoint (0xca)"
    254 -> "impdep1 (0xfe)"
    255 -> "impdep2 (0xff)"
    -- Bad OP code
    _ -> printf "0x%x" bc
