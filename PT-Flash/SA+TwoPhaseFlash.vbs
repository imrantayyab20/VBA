'This algorithm is taken from Abbas Firozabadi Chapter-4 and Sandler book.

Sub SATwoPhaseFlash()

Start:

On Error Resume Next




'Declaring some variables
Dim ZiArray()
Dim TcArray()
Dim PcArray()
Dim OmegaArray()
Dim KappaArray()
Dim AlphaArray()
Dim aiArray()
Dim aijArray()
Dim biArray()
Dim BigAiArray()
Dim BigBiArray()
Dim KijArray()
Dim Nc As Double
Dim i As Double
Dim j As Double
Dim T As Double
Dim P As Double
Dim R As Double
Dim Zamix As Double
Dim Zbmix As Double
Dim ZBigAmix As Double
Dim ZBigBmix As Double
Dim amix As Double
Dim bmix As Double
Dim BigAmix As Double
Dim BigBmix As Double
Dim iteration As Double
iteration = 1

'Setting initial values based on user input
T = Range("SATemp").Value
P = Range("SAPress").Value
R = Range("SARConst").Value
Nc = Range("SANc").Value - 1

'Conducting some housekeeping
For i = 0 To Nc
Range("SATableXiHead").SelectC
ActiveCell.Offset(i + 1, 0).Select
    Selection.ClearContents
Range("SATableYiHead").Select
ActiveCell.Offset(i + 1, 0).Select
    Selection.ClearContents
Next i
Range("SAOnePhaseCalculatedBv").Select
    Selection.ClearContents
Range("SATableErrorColoumn").Select
Selection.ClearContents

'Checking if total mole fraction equals to 1
Dim totalZ As Double
totalZ = 0
For i = 0 To Nc
    Range("SATableZiHead").Select
    totalZ = totalZ + ActiveCell.Offset(i + 1, 0).Value
Next i
Range("SATableTotalZ").Value = totalZ
    
    
    If totalZ > 1 Then
        Range("SATableTotalZ").Select
        MsgBox "Total Zi exceeds 1. Check feed composition", 16, "Error!"
        End
    'ElseIf totalZ < 1 Then
        'Range("SATableTotalZ").Select
        'MsgBox "Total Zi is less than 1. Check feed composition", 16, "Error!"
        'End
    End If

'Creating array for Tc
ReDim TcArray(Nc)
For i = 0 To Nc
Range("SATableTcHead").Select
TcArray(i) = ActiveCell.Offset(i + 1, 0).Value
Next i

'Creating array for Pc
ReDim PcArray(Nc)
For i = 0 To Nc
Range("SATablePcHead").Select
PcArray(i) = ActiveCell.Offset(i + 1, 0).Value
Next i

'Creating array for Zi
ReDim ZiArray(Nc)
For i = 0 To Nc
Range("SATableZiHead").Select
ZiArray(i) = ActiveCell.Offset(i + 1, 0).Value
Next i

'Creating array for omega
ReDim OmegaArray(Nc)
For i = 0 To Nc
Range("SATableOmegaHead").Select
OmegaArray(i) = ActiveCell.Offset(i + 1, 0).Value
Next i

'Creating Array for Kij
ReDim KijArray(Nc, Nc)
For i = 0 To Nc
    For j = 0 To Nc
        Range("SATableKijHead").Select
        KijArray(i, j) = ActiveCell.Offset(i + 1, j + 1).Value
    Next j
Next i

    ' ******************check code*************************************
    'For i = 0 To Nc
        'For j = 0 To Nc
            'Range("X38").Select
            'ActiveCell.Offset(i + 1, j + 1).Value = KijArray(i, j)
        'Next j
    'Next i
    
    '*******************end check code************************************

'Estimating Kappa from omega and storing it in array for future use
ReDim KappaArray(Nc)
For i = 0 To Nc
    If OmegaArray(i) > 0.49 Then
        KappaArray(i) = 0.37464 + OmegaArray(i) * (1.48503 + OmegaArray(i) * (-0.164423 + 0.016666 * OmegaArray(i)))
    Else
        KappaArray(i) = 0.37464 + 1.54226 * OmegaArray(i) - 0.26992 * ((OmegaArray(i)) ^ 2)
    End If
Next i

'Estimating Alpha for each component and storing it in array for future use
ReDim AlphaArray(Nc)
For i = 0 To Nc
    AlphaArray(i) = ((1 + KappaArray(i) * (1 - ((T / TcArray(i)) ^ 0.5))) ^ 2)
Next i

'Estimating Pure component PR a value for each component
ReDim aiArray(Nc)
For i = 0 To Nc
    aiArray(i) = 0.457236 * AlphaArray(i) * (((R * TcArray(i)) ^ 2) / (PcArray(i)))
Next i

'Estimating Pure component PR b value For each component
ReDim biArray(Nc)
For i = 0 To Nc
    biArray(i) = 0.0778 * ((R * TcArray(i)) / PcArray(i))
Next i

'Estimating Pure component PR Ai value foe each component
ReDim BigAiArray(Nc)
For i = 0 To Nc
    BigAiArray(i) = (aiArray(i) * P) / ((R * T) ^ 2)
Next i

'Estimating Pure component PR Bi value foe each component
ReDim BigBiArray(Nc)
For i = 0 To Nc
    BigBiArray(i) = (biArray(i) * P) / (R * T)
Next i

        '***************************This code is to check only***********************************
        
        'For i = 0 To Nc
            'Range("Q50").Select
            'ActiveCell.Offset(i + 1, 0).Value = ZiArray(i)
            'ActiveCell.Offset(i + 1, 1).Value = TcArray(i)
            'ActiveCell.Offset(i + 1, 2).Value = PcArray(i)
            'ActiveCell.Offset(i + 1, 3).Value = OmegaArray(i)
            'ActiveCell.Offset(i + 1, 4).Value = KappaArray(i)
            'ActiveCell.Offset(i + 1, 5).Value = AlphaArray(i)
            'ActiveCell.Offset(i + 1, 6).Value = aiArray(i)
            'ActiveCell.Offset(i + 1, 7).Value = biArray(i)
            'ActiveCell.Offset(i + 1, 8).Value = BigAiArray(i)
            'ActiveCell.Offset(i + 1, 9).Value = BigBiArray(i)
        'Next i
        
        ' *******************************End of check code*******************************************

'Estimating aij for each pair
ReDim aijArray(Nc, Nc)
For i = 0 To Nc
    For j = 0 To Nc
        aijArray(i, j) = ((aiArray(i) * aiArray(j)) ^ 0.5) * (1 - KijArray(i, j))
    Next j
Next i

'*************************************************************************************************************************'
'*******************************************This is step 1 of algorithm***************************************************
'*************************************************************************************************************************'

'Estimating amix for Z overall composition
Zamix = 0
For i = 0 To Nc
    For j = 0 To Nc
        Zamix = Zamix + ZiArray(i) * ZiArray(j) * aijArray(i, j)
    Next j
Next i

'Estimating bmix for Z overall composition
Zbmix = 0
For i = 0 To Nc
    Zbmix = Zbmix + ZiArray(i) * biArray(i)
Next i

'Calculating BigAmix for overall composition
ZBigAmix = (Zamix * P) / ((R * T) ^ 2)

'Calculating BigBmix for overal composition
ZBigBmix = (Zbmix * P) / (R * T)

'Using Cardano cubic root solver to estimate Z
Dim CarD As Double
Dim CarE As Double
Dim CarF As Double
Dim CarG As Double
Dim CarDel As Double
Dim Ang As Double
Dim CarA As Double
Dim CarB As Double
Dim CarC As Double
Dim x1 As Double
Dim x2 As Double
Dim x3 As Double
Dim Z As Double
Dim Z1 As Double
Dim Z2 As Double
Dim lnphiZArray()
Dim lnphi1Array()
Dim lnphi2Array()
Dim lnphiXArray()
Dim FugacityArray()
Dim DelGdimen As Double
Dim yiaij As Double
yiaij = 0


'Calculating A,B and C for Cardano

CarA = (-1 + ZBigBmix)
CarB = (ZBigAmix - (3 * ((ZBigBmix) ^ 2)) - (2 * ZBigBmix))
CarC = ((-ZBigAmix * ZBigBmix) + ((ZBigBmix) ^ 2) + ((ZBigBmix) ^ 3))

'Running Cardano solution
    CarD = ((CarA / 3) ^ 3) - ((CarA * CarB) / 6) + (CarC / 2)
    CarE = (CarB / 3) - ((CarA / 3) ^ 2)

    CarDel = ((CarD) ^ 2) + ((CarE) ^ 3)

    'Solving the cubic equation based on value of Z

        If CarDel = 0 Then
            x1 = (2 * (-(CarD) ^ (1 / 3))) - (CarA / 3)
            x2 = (-1 * (-(CarD) ^ (1 / 3))) - (CarA / 3)
            x3 = x2
        ElseIf CarDel > 0 Then
            CarF = Application.WorksheetFunction.Power(((-CarD) + (((CarDel) ^ 0.5))), 1 / 3)
            CarG = Application.WorksheetFunction.Power(((-CarD) - (((CarDel) ^ 0.5))), 1 / 3)
            x1 = CarF + CarG - (CarA / 3)
        ElseIf CarDel < 0 Then
            Ang = Application.WorksheetFunction.Acos(-CarD / ((-(CarE) ^ 3) ^ 0.5))
            x1 = 2 * ((-CarE) ^ 0.5) * Cos(Ang / 3) - (CarA / 3)
            x2 = 2 * ((-CarE) ^ 0.5) * Cos((Ang / 3) + ((2 / 3) * 3.14159)) - (CarA / 3)
            x3 = 2 * ((-CarE) ^ 0.5) * Cos((Ang / 3) + ((4 / 3) * 3.14159)) - (CarA / 3)
        End If
    
    'Sorting roots to define Z value
    If CarDel > 0 Then
        Z = x1
    ElseIf CarDel < 0 Then
        
        'As we have more than one real root, we will need to use robust root selection method
        Z1 = WorksheetFunction.Max(x1, x2, x3)
        Z2 = WorksheetFunction.Min(x1, x2, x3)


        'Estimating ln phi function for both roots
        ReDim lnphi1Array(Nc)
        ReDim lnphi2Array(Nc)
      
        For i = 0 To Nc
        yiaij = 0
                'Calculating yiaij for estimation of lnphi Array (this is required in ln phi formula)
                For j = 0 To Nc
                    yiaij = yiaij + ZiArray(j) * aijArray(i, j)
                Next j
        
            lnphi1Array(i) = (((biArray(i) / Zbmix) * (Z1 - 1)) - (WorksheetFunction.Ln((Z1 - ((Zbmix * P) / (R * T))))) - (((Zamix / (((8) ^ 0.5) * Zbmix * R * T))) * (((2 * yiaij) / Zamix) - (biArray(i) / Zbmix)) * (WorksheetFunction.Ln(((Z1 + (1 + ((2) ^ 0.5)) * ((Zbmix * P) / (R * T))) / (Z1 + (1 - ((2) ^ 0.5)) * ((Zbmix * P) / (R * T))))))))
            lnphi2Array(i) = (((biArray(i) / Zbmix) * (Z2 - 1)) - (WorksheetFunction.Ln((Z2 - ((Zbmix * P) / (R * T))))) - (((Zamix / (((8) ^ 0.5) * Zbmix * R * T))) * (((2 * yiaij) / Zamix) - (biArray(i) / Zbmix)) * (WorksheetFunction.Ln(((Z2 + (1 + ((2) ^ 0.5)) * ((Zbmix * P) / (R * T))) / (Z2 + (1 - ((2) ^ 0.5)) * ((Zbmix * P) / (R * T))))))))
            
        Next i

        'Estimating Delta G dimensionless function to select root
        DelGdimen = 0
        For i = 0 To Nc
            DelGdimen = DelGdimen + (ZiArray(i) * (lnphi1Array(i) - lnphi2Array(i)))
        Next i

        If DelGdimen > 0 Then
            Z = Z2
        ElseIf DelGdimen < 0 Then
            Z = Z1
        End If
    End If

    ' ******************check code*************************************
        'Range("P7").Value = CarDel
        'Range("P8").Value = Z
        'Range("P9").Value = x1
        'Range("P10").Value = x2
        'Range("P11").Value = x3
        'Range("P12").Value = Zamix
        'Range("P13").Value = Zbmix
    '*******************end check code************************************


'Now that we have Z, we can estimate partial molar fugacity for each component
ReDim lnphiZArray(Nc)
For i = 0 To Nc
yiaij = 0
                'Calculating yiaij for estimation of lnphi Array (this is required in ln phi formula)
                For j = 0 To Nc
                    yiaij = yiaij + ZiArray(j) * aijArray(i, j)
                Next j

    lnphiZArray(i) = (((biArray(i) / Zbmix) * (Z - 1)) - (WorksheetFunction.Ln((Z - ((Zbmix * P) / (R * T))))) - (((Zamix / (((8) ^ 0.5) * Zbmix * R * T))) * (((2 * yiaij) / Zamix) - (biArray(i) / Zbmix)) * (WorksheetFunction.Ln(((Z + (1 + ((2) ^ 0.5)) * ((Zbmix * P) / (R * T))) / (Z + (1 - ((2) ^ 0.5)) * ((Zbmix * P) / (R * T))))))))
   
Next i



' creating intial estimate for Xi using Gas-like and Vapor-like phase - this grandloop will try convergence with both intial Ki estimates
Dim localcount As Double
Dim KiArray()
Dim XiArray()
Dim smallXiArray()
Dim totalXi As Double
Dim Selector As Integer
Dim StablePhase As Integer
Dim Xamix As Double
Dim Xbmix As Double
Dim XBigAmix As Double
Dim XBigBmix As Double
Dim Threshold As Double
Dim error As Double
Dim ErrorArray()

Threshold = Range("SAOnePhaseThreshold").Value

iteration = 0
Selector = 1


    ReDim XiArray(Nc)
    ReDim KiArray(Nc)
    ReDim smallXiArray(Nc)
    ReDim ErrorArray(Range("SAOnePhaseMaxIteration").Value)
    '*************************************************************************************************************************'
    '*******************************************This is step 2 of algorithm***************************************************
    '*************************************************************************************************************************'

    'Intial estimate of Ki from Wilson corelation
        For i = 0 To Nc
        KiArray(i) = (PcArray(i) / P) * (Exp(5.373 * (1 + OmegaArray(i)) * (1 - (TcArray(i) / T))))
        Next i

Step1:
 
       If Selector = 1 Then
            'initial estimate of Xi from Gas-like phase
            For i = 0 To Nc
                XiArray(i) = ZiArray(i) / KiArray(i)
                'XiArray(i) = KiArray(i) * ZiArray(i)
                    '*****check code**********
                    'Range("H18").Select
                    'ActiveCell.Offset(i, 0).Value = XiArray(i)
                    'Range("P3").Value = Range("P3").Value + 1
                    '*****end check code*************************
            Next i
        ElseIf Selector = 2 Then
            'initial estimate of Xi from liquid-like phase
            For i = 0 To Nc
                XiArray(i) = KiArray(i) * ZiArray(i)
                'XiArray(i) = ZiArray(i) / KiArray(i)
                    '*****check code******************
                    'Range("J18").Select
                    'ActiveCell.Offset(i, 0).Value = XiArray(i)
                    '*****end check code************************
            Next i
            StablePhase = 1
        End If

Step3:

'max iteration counter
iteration = iteration + 1
Range("SAOnePhaseStabilityIteration").Value = iteration

    '*************************************************************************************************************************'
    '*******************************************This is step 3 of algorithm***************************************************
    '*************************************************************************************************************************'

    'creating mole fractions small xi from big Xi
    totalXi = 0
    For i = 0 To Nc
        totalXi = totalXi + XiArray(i)
    Next i


    For i = 0 To Nc
        smallXiArray(i) = XiArray(i) / totalXi
    Next i
    
    '*************************************************************************************************************************'
    '*******************************************This is step 4 of algorithm***************************************************
    '*************************************************************************************************************************'


    
    'Estimating amix for small xi overall composition
    Xamix = 0
    For i = 0 To Nc
        For j = 0 To Nc
            Xamix = Xamix + smallXiArray(i) * smallXiArray(j) * aijArray(i, j)
        Next j
    Next i

    'Estimating bmix for small xi overall composition
    Xbmix = 0
    For i = 0 To Nc
        Xbmix = Xbmix + smallXiArray(i) * biArray(i)
    Next i

    'Calculating BigAmix for overall composition
    XBigAmix = (Xamix * P) / ((R * T) ^ 2)

    'Calculating BigBmix for overal composition
    XBigBmix = (Xbmix * P) / (R * T)

        'Calculating A,B and C for Cardano

        CarA = (-1 + XBigBmix)
        CarB = (XBigAmix - (3 * ((XBigBmix) ^ 2)) - (2 * XBigBmix))
        CarC = ((-XBigAmix * XBigBmix) + ((XBigBmix) ^ 2) + ((XBigBmix) ^ 3))

        'Running Cardano solution
            CarD = ((CarA / 3) ^ 3) - ((CarA * CarB) / 6) + (CarC / 2)
            CarE = (CarB / 3) - ((CarA / 3) ^ 2)

            CarDel = ((CarD) ^ 2) + ((CarE) ^ 3)

            'Solving the cubic equation based on value of Z

            If CarDel = 0 Then
                x1 = (2 * (-(CarD) ^ (1 / 3))) - (CarA / 3)
                x2 = (-1 * (-(CarD) ^ (1 / 3))) - (CarA / 3)
                x3 = x2
            ElseIf CarDel > 0 Then
                CarF = Application.WorksheetFunction.Power(((-CarD) + (((CarDel) ^ 0.5))), 1 / 3)
                CarG = Application.WorksheetFunction.Power(((-CarD) - (((CarDel) ^ 0.5))), 1 / 3)
                x1 = CarF + CarG - (CarA / 3)
            ElseIf CarDel < 0 Then
                Ang = Application.WorksheetFunction.Acos(-CarD / ((-(CarE) ^ 3) ^ 0.5))
                x1 = 2 * ((-CarE) ^ 0.5) * Cos(Ang / 3) - (CarA / 3)
                x2 = 2 * ((-CarE) ^ 0.5) * Cos((Ang / 3) + ((2 / 3) * 3.14159)) - (CarA / 3)
                x3 = 2 * ((-CarE) ^ 0.5) * Cos((Ang / 3) + ((4 / 3) * 3.14159)) - (CarA / 3)
            End If
            
            'Sorting roots to define Z value
            If CarDel > 0 Then
                Z = x1
            ElseIf CarDel < 0 Then
                
                'As we have more than one real root, we will need to use robust root selection method
                Z1 = WorksheetFunction.Max(x1, x2, x3)
                Z2 = WorksheetFunction.Min(x1, x2, x3)


                'Estimating ln phi function for both roots
                ReDim lnphi1Array(Nc)
                ReDim lnphi2Array(Nc)
              
                For i = 0 To Nc
                yiaij = 0
                        'Calculating yiaij for estimation of lnphi Array (this is required in ln phi formula)
                        For j = 0 To Nc
                            yiaij = yiaij + smallXiArray(j) * aijArray(i, j)
                        Next j
                
                    lnphi1Array(i) = (((biArray(i) / Xbmix) * (Z1 - 1)) - (WorksheetFunction.Ln((Z1 - ((Xbmix * P) / (R * T))))) - (((Xamix / (((8) ^ 0.5) * Xbmix * R * T))) * (((2 * yiaij) / Xamix) - (biArray(i) / Xbmix)) * (WorksheetFunction.Ln(((Z1 + (1 + ((2) ^ 0.5)) * ((Xbmix * P) / (R * T))) / (Z1 + (1 - ((2) ^ 0.5)) * ((Xbmix * P) / (R * T))))))))
                    lnphi2Array(i) = (((biArray(i) / Xbmix) * (Z2 - 1)) - (WorksheetFunction.Ln((Z2 - ((Xbmix * P) / (R * T))))) - (((Xamix / (((8) ^ 0.5) * Xbmix * R * T))) * (((2 * yiaij) / Xamix) - (biArray(i) / Xbmix)) * (WorksheetFunction.Ln(((Z2 + (1 + ((2) ^ 0.5)) * ((Xbmix * P) / (R * T))) / (Z2 + (1 - ((2) ^ 0.5)) * ((Xbmix * P) / (R * T))))))))
                    
                Next i

                'Estimating Delta G dimensionless function to select root
                DelGdimen = 0
                For i = 0 To Nc
                    DelGdimen = DelGdimen + (smallXiArray(i) * (lnphi1Array(i) - lnphi2Array(i)))
                Next i

                If DelGdimen > 0 Then
                    Z = Z2
                ElseIf DelGdimen < 0 Then
                    Z = Z1
                End If
            End If

            ' ******************check code*************************************
                'Range("R18").Value = Z
                'Range("R19").Value = CarDel
                'Range("R20").Value = Zbmix
            
            '*******************end check code************************************


            'Now that we have Z, we can estimate partial molar fugacity for each component
            ReDim lnphiXArray(Nc)
            For i = 0 To Nc
            yiaij = 0
                            'Calculating yiaij for estimation of lnphi Array (this is required in ln phi formula)
                            For j = 0 To Nc
                                yiaij = yiaij + smallXiArray(j) * aijArray(i, j)
                            Next j

                lnphiXArray(i) = (((biArray(i) / Xbmix) * (Z - 1)) - (WorksheetFunction.Ln((Z - ((Xbmix * P) / (R * T))))) - (((Xamix / (((8) ^ 0.5) * Xbmix * R * T))) * (((2 * yiaij) / Xamix) - (biArray(i) / Xbmix)) * (WorksheetFunction.Ln(((Z + (1 + ((2) ^ 0.5)) * ((Xbmix * P) / (R * T))) / (Z + (1 - ((2) ^ 0.5)) * ((Xbmix * P) / (R * T))))))))
               
            Next i

    '*************************************************************************************************************************'
    '*******************************************This is step 5 of algorithm***************************************************
    '*************************************************************************************************************************'

    'checking if convergence is met

    For i = 0 To Nc
        error = Abs(WorksheetFunction.Ln(XiArray(i)) + lnphiXArray(i) - WorksheetFunction.Ln(ZiArray(i)) - lnphiZArray(i))
                '*****check code***********
                'Range("S7").Select
                'ActiveCell.Offset(i, 0).Value = error
                '*****end check code*************
        ErrorArray(iteration) = error
        If error > Threshold And iteration < Range("SAOnePhaseMaxIteration").Value Then
            'inloop = 1
            GoTo Step10
        End If
    Next i

' Calculation is completed, showing results

Dim Answer As Integer

Range("SAOnePhaseTOtalXi").Value = totalXi
If iteration > Range("SAOnePhaseMaxIteration").Value Or iteration = Range("SAOnePhaseMaxIteration").Value Then
    Answer = MsgBox("Max iteration reached before solution could converge. Do you want to increase iteration limit?", vbYesNo + vbExclamation, "Max Iteration Reached!")
        If Answer = vbYes Then
            Range("SAOnePhaseMaxIteration").Value = InputBox("Enter maximum iteration limit", "Iteration Limit")
            GoTo Start
        Else
        End
        End If
ElseIf totalXi < 1 Or totalXi = 1 Then
    If StablePhase = 1 Then
        MsgBox "Input Feed is stable one phase ", 64, "Phase Stable!"
            'creating the error table to ensure accuracy
            For i = 0 To iteration
                Range("SATableErrorHead").Select
                ActiveCell.Offset(i + 1, 0).Value = ErrorArray(i)
            Next i
        End
    Else
    totalXi = 1.1
    Selector = 2
    GoTo Step1
    End If
   
ElseIf totalXi > 1 Then
            'creating the error table to ensure accuracy
            For i = 0 To iteration
                Range("SATableErrorHead").Select
                ActiveCell.Offset(i + 1, 0).Value = ErrorArray(i)
            Next i
    GoTo PhaseSplit
End If


    ' ******************check code*************************************
        'Range("P16").Value = Xamix
        'Range("P17").Value = Xbmix
        'Range("P18").Value = inloop
        'Range("P19").Value = error
        'Range("P20").Value = totalXi

    
    '*******************end check code************************************
        
Step10:
        For i = 0 To Nc
        XiArray(i) = (ZiArray(i) * Exp(lnphiZArray(i))) / (Exp(lnphiXArray(i)))
                    '*****check code*******************
                    'Range("L18").Select
                    'ActiveCell.Offset(i, 0).Value = XiArray(i)
                    '*****end check code********************
        Next i
        GoTo Step3

    '*************************************************************************************************************************'
    '*************************************************************************************************************************'
    '*******************************************This is PT flash algorithm****************************************************
    '*************************************************************************************************************************'
    '*************************************************************************************************************************'

PhaseSplit:

Dim RRArray()
Dim RRPrimeArray()
Dim Bv As Double
Dim TotalRR As Double
Dim TotalRRPrime As Double
Dim Kmax As Double
Dim KmaxPole As Double
Dim Kmin As Double
Dim KminPole As Double
Dim PhaseXiComposition()
Dim PhaseYiComposition()
Dim lnphiLArray()
Dim lnphiVArray()
Dim FugacityV()
Dim FugacityL()
Dim ErrorArrayFlash()
'Dim localcount As Integer
iteration = 0
ReDim ErrorArrayFlash(Range("SAOnePhaseMaxIteration").Value)
    '*************************************************************************************************************************'
    '**************************************This is step 2 of algorithm of 2 phase PT Flash************************************
    '*************************************************************************************************************************'

    'Intial estimate of Ki from Wilson corelation
        ReDim KiArray(Nc)
        For i = 0 To Nc
        KiArray(i) = (PcArray(i) / P) * (Exp(5.373 * (1 + OmegaArray(i)) * (1 - (TcArray(i) / T))))
        Next i

Bv = (KminPole + KmaxPole) / 2


Step2:

'adding to iteration to ensure max iterations are not exceeded
iteration = iteration + 1
Range("SAOnePhasePTFlashIteration").Value = iteration



'Estimating Kmax/Kmin Pole to handle under/over relaxation of Bv
Kmax = Application.WorksheetFunction.Max(KiArray)
'Range("P23").Value = Kmax
KmaxPole = 1 / (1 - Kmax)
    'If KmaxPole < 0 Then
        'KmaxPole = 0
    'End If
'Range("P24").Value = KmaxPole
Kmin = Application.WorksheetFunction.Min(KiArray)
'Range("P25").Value = Kmin
KminPole = 1 / (1 - Kmin)
    'If KminPole > 0 Then
        'KmaxPole = 1
    'End If
'Range("P26").Value = KminPole


Bv = (KminPole + KmaxPole) / 2
TotalRR = 1

'estimating RR function and derivative for each Ki and Bv
ReDim RRArray(Nc)
ReDim RRPrimeArray(Nc)

Do While Abs(TotalRR) > Threshold
    
    For i = 0 To Nc
        RRArray(i) = ((1 - KiArray(i)) * ZiArray(i)) / (1 - ((1 - KiArray(i)) * Bv))
        RRPrimeArray(i) = (((KiArray(i) - 1) ^ 2) * ZiArray(i)) / ((((KiArray(i) - 1) * Bv) + 1) ^ 2)
    Next i

    'computing total RR function
    TotalRR = 0
    TotalRRPrime = 0
    For i = 0 To Nc
        TotalRR = TotalRR + RRArray(i)
        TotalRRPrime = TotalRRPrime + RRPrimeArray(i)
    Next i

    'Updating Bv based on newton iteration
    Bv = Bv - (TotalRR / TotalRRPrime)

    'Checking for under/over relaxation of Bv
    If Bv < KmaxPole Then
        Bv = 0.5 * (Bv + KmaxPole)
    ElseIf Bv > KminPole Then
        Bv = 0.5 * (Bv + KminPole)
    End If

Loop

' estimating phase xi & yi composition from estimated Bv
ReDim PhaseXiComposition(Nc)
ReDim PhaseYiComposition(Nc)

For i = 0 To Nc
PhaseXiComposition(i) = ZiArray(i) / (1 + (Bv * (KiArray(i) - 1)))
PhaseYiComposition(i) = KiArray(i) * PhaseXiComposition(i)
Next i

Range("SAOnePhaseCalculatedBv").Value = Bv

    '*************************************************************************************************************************'
    '**************************************This is step 3 of algorithm of 2 phase PT Flash************************************
    '*************************************************************************************************************************'

    '****************Solving for Xi phase**********************************************************

        For i = 0 To Nc
        ZiArray(i) = PhaseXiComposition(i)
        Next i

    'Estimating amix for Z overall composition
    amix = 0
    For i = 0 To Nc
        For j = 0 To Nc
            amix = amix + ZiArray(i) * ZiArray(j) * aijArray(i, j)
        Next j
    Next i

    'Estimating bmix for Z overall composition
    bmix = 0
    For i = 0 To Nc
        bmix = bmix + ZiArray(i) * biArray(i)
    Next i

    'Calculating BigAmix for overall composition
    BigAmix = 0
    BigAmix = (amix * P) / ((R * T) ^ 2)

    'Calculating BigBmix for overal composition
    BigBmix = 0
    BigBmix = (bmix * P) / (R * T)

        '*************************************************************************************************************************'
        '**************************************This is step 4 & 5 of algorithm of 2 phase PT Flash********************************
        '*************************************************************************************************************************'


    'Calculating A,B and C for Cardano

    CarA = (-1 + BigBmix)
    CarB = (BigAmix - (3 * ((BigBmix) ^ 2)) - (2 * BigBmix))
    CarC = ((-BigAmix * BigBmix) + ((BigBmix) ^ 2) + ((BigBmix) ^ 3))

    'Running Cardano solution
        CarD = ((CarA / 3) ^ 3) - ((CarA * CarB) / 6) + (CarC / 2)
        CarE = (CarB / 3) - ((CarA / 3) ^ 2)

        CarDel = ((CarD) ^ 2) + ((CarE) ^ 3)

        'Solving the cubic equation based on value of Z

            If CarDel = 0 Then
                x1 = (2 * (-(CarD) ^ (1 / 3))) - (CarA / 3)
                x2 = (-1 * (-(CarD) ^ (1 / 3))) - (CarA / 3)
                x3 = x2
            ElseIf CarDel > 0 Then
                CarF = Application.WorksheetFunction.Power(((-CarD) + (((CarDel) ^ 0.5))), 1 / 3)
                CarG = Application.WorksheetFunction.Power(((-CarD) - (((CarDel) ^ 0.5))), 1 / 3)
                x1 = CarF + CarG - (CarA / 3)
            ElseIf CarDel < 0 Then
                Ang = Application.WorksheetFunction.Acos(-CarD / ((-(CarE) ^ 3) ^ 0.5))
                x1 = 2 * ((-CarE) ^ 0.5) * Cos(Ang / 3) - (CarA / 3)
                x2 = 2 * ((-CarE) ^ 0.5) * Cos((Ang / 3) + ((2 / 3) * 3.14159)) - (CarA / 3)
                x3 = 2 * ((-CarE) ^ 0.5) * Cos((Ang / 3) + ((4 / 3) * 3.14159)) - (CarA / 3)
            End If
        
        'Sorting roots to define Z value
        If CarDel > 0 Then
            Z = x1
        ElseIf CarDel < 0 Then
            
            'As we have more than one real root, we will need to use robust root selection method
            Z1 = WorksheetFunction.Max(x1, x2, x3)
            Z2 = WorksheetFunction.Min(x1, x2, x3)
            
            'If Z2 < 0 Then
            'Z2 = WorksheetFunction.Median(x1, x2, x3)
            'End If
    
    ' ******************check code*************************************
        'Range("L19").Value = CarDel
        'Range("L20").Value = Z1
        'Range("L21").Value = Z2
        'Range("L22").Value = Z
    ' ****************** end check code*********************************
            
            'Estimating ln phi function for both roots
            ReDim lnphi1Array(Nc)
            ReDim lnphi2Array(Nc)
          
            For i = 0 To Nc
            yiaij = 0
                    'Calculating yiaij for estimation of lnphi Array (this is required in ln phi formula)
                    For j = 0 To Nc
                        yiaij = yiaij + ZiArray(j) * aijArray(i, j)
                    Next j
            
                lnphi1Array(i) = (((biArray(i) / bmix) * (Z1 - 1)) - (WorksheetFunction.Ln((Z1 - ((bmix * P) / (R * T))))) - (((amix / (((8) ^ 0.5) * bmix * R * T))) * (((2 * yiaij) / amix) - (biArray(i) / bmix)) * (WorksheetFunction.Ln(((Z1 + (1 + ((2) ^ 0.5)) * ((bmix * P) / (R * T))) / (Z1 + (1 - ((2) ^ 0.5)) * ((bmix * P) / (R * T))))))))
                lnphi2Array(i) = (((biArray(i) / bmix) * (Z2 - 1)) - (WorksheetFunction.Ln((Z2 - ((bmix * P) / (R * T))))) - (((amix / (((8) ^ 0.5) * bmix * R * T))) * (((2 * yiaij) / amix) - (biArray(i) / bmix)) * (WorksheetFunction.Ln(((Z2 + (1 + ((2) ^ 0.5)) * ((bmix * P) / (R * T))) / (Z2 + (1 - ((2) ^ 0.5)) * ((bmix * P) / (R * T))))))))
                
            Next i

            'Estimating Delta G dimensionless function to select root
            DelGdimen = 0
            For i = 0 To Nc
                DelGdimen = DelGdimen + (ZiArray(i) * (lnphi1Array(i) - lnphi2Array(i)))
            Next i

            If DelGdimen > 0 Then
                Z = Z2
            ElseIf DelGdimen < 0 Then
                Z = Z1
            End If
        End If

    'Now that we have Z, we can estimate partial molar fugacity for L component
    ReDim lnphiLArray(Nc)
    ReDim FugacityL(Nc)

        For i = 0 To Nc
        yiaij = 0
                        'Calculating yiaij for estimation of lnphi Array (this is required in ln phi formula)
                        For j = 0 To Nc
                            yiaij = yiaij + ZiArray(j) * aijArray(i, j)
                        Next j

            lnphiLArray(i) = (((biArray(i) / bmix) * (Z - 1)) - (WorksheetFunction.Ln((Z - ((bmix * P) / (R * T))))) - (((amix / (((8) ^ 0.5) * bmix * R * T))) * (((2 * yiaij) / amix) - (biArray(i) / bmix)) * (WorksheetFunction.Ln(((Z + (1 + ((2) ^ 0.5)) * ((bmix * P) / (R * T))) / (Z + (1 - ((2) ^ 0.5)) * ((bmix * P) / (R * T))))))))
            FugacityL(i) = Exp(lnphiLArray(i)) * P * ZiArray(i)
        Next i

    '****************Solving for Yi phase**********************************************************


        For i = 0 To Nc
        ZiArray(i) = PhaseYiComposition(i)
        Next i

    'Estimating amix for Z overall composition
    amix = 0
    For i = 0 To Nc
        For j = 0 To Nc
            amix = amix + ZiArray(i) * ZiArray(j) * aijArray(i, j)
        Next j
    Next i

    'Estimating bmix for Z overall composition
    bmix = 0
    For i = 0 To Nc
        bmix = bmix + ZiArray(i) * biArray(i)
    Next i

    'Calculating BigAmix for overall composition
    BigAmix = 0
    BigAmix = (amix * P) / ((R * T) ^ 2)

    'Calculating BigBmix for overal composition
    BigBmix = 0
    BigBmix = (bmix * P) / (R * T)

        '*************************************************************************************************************************'
        '**************************************This is step 4 & 5 of algorithm of 2 phase PT Flash********************************
        '*************************************************************************************************************************'


    'Calculating A,B and C for Cardano

    CarA = (-1 + BigBmix)
    CarB = (BigAmix - (3 * ((BigBmix) ^ 2)) - (2 * BigBmix))
    CarC = ((-BigAmix * BigBmix) + ((BigBmix) ^ 2) + ((BigBmix) ^ 3))

    'Running Cardano solution
        CarD = ((CarA / 3) ^ 3) - ((CarA * CarB) / 6) + (CarC / 2)
        CarE = (CarB / 3) - ((CarA / 3) ^ 2)

        CarDel = ((CarD) ^ 2) + ((CarE) ^ 3)

        'Solving the cubic equation based on value of Z

            If CarDel = 0 Then
                x1 = (2 * (-(CarD) ^ (1 / 3))) - (CarA / 3)
                x2 = (-1 * (-(CarD) ^ (1 / 3))) - (CarA / 3)
                x3 = x2
            ElseIf CarDel > 0 Then
                CarF = Application.WorksheetFunction.Power(((-CarD) + (((CarDel) ^ 0.5))), 1 / 3)
                CarG = Application.WorksheetFunction.Power(((-CarD) - (((CarDel) ^ 0.5))), 1 / 3)
                x1 = CarF + CarG - (CarA / 3)
            ElseIf CarDel < 0 Then
                Ang = Application.WorksheetFunction.Acos(-CarD / ((-(CarE) ^ 3) ^ 0.5))
                x1 = 2 * ((-CarE) ^ 0.5) * Cos(Ang / 3) - (CarA / 3)
                x2 = 2 * ((-CarE) ^ 0.5) * Cos((Ang / 3) + ((2 / 3) * 3.14159)) - (CarA / 3)
                x3 = 2 * ((-CarE) ^ 0.5) * Cos((Ang / 3) + ((4 / 3) * 3.14159)) - (CarA / 3)
            End If
        
        'Sorting roots to define Z value
        If CarDel > 0 Then
            Z = x1
        ElseIf CarDel < 0 Then
            
            'As we have more than one real root, we will need to use robust root selection method
            Z1 = WorksheetFunction.Max(x1, x2, x3)
            Z2 = WorksheetFunction.Min(x1, x2, x3)
            
            'If Z2 < 0 Then
            'Z2 = WorksheetFunction.Median(x1, x2, x3)
            'End If

            'Estimating ln phi function for both roots
            ReDim lnphi1Array(Nc)
            ReDim lnphi2Array(Nc)
          
            For i = 0 To Nc
            yiaij = 0
                    'Calculating yiaij for estimation of lnphi Array (this is required in ln phi formula)
                    For j = 0 To Nc
                        yiaij = yiaij + ZiArray(j) * aijArray(i, j)
                    Next j
            
                lnphi1Array(i) = (((biArray(i) / bmix) * (Z1 - 1)) - (WorksheetFunction.Ln((Z1 - ((bmix * P) / (R * T))))) - (((amix / (((8) ^ 0.5) * bmix * R * T))) * (((2 * yiaij) / amix) - (biArray(i) / bmix)) * (WorksheetFunction.Ln(((Z1 + (1 + ((2) ^ 0.5)) * ((bmix * P) / (R * T))) / (Z1 + (1 - ((2) ^ 0.5)) * ((bmix * P) / (R * T))))))))
                lnphi2Array(i) = (((biArray(i) / bmix) * (Z2 - 1)) - (WorksheetFunction.Ln((Z2 - ((bmix * P) / (R * T))))) - (((amix / (((8) ^ 0.5) * bmix * R * T))) * (((2 * yiaij) / amix) - (biArray(i) / bmix)) * (WorksheetFunction.Ln(((Z2 + (1 + ((2) ^ 0.5)) * ((bmix * P) / (R * T))) / (Z2 + (1 - ((2) ^ 0.5)) * ((bmix * P) / (R * T))))))))
                
            Next i

            'Estimating Delta G dimensionless function to select root
            DelGdimen = 0
            For i = 0 To Nc
                DelGdimen = DelGdimen + (ZiArray(i) * (lnphi1Array(i) - lnphi2Array(i)))
            Next i

            If DelGdimen > 0 Then
                Z = Z2
            ElseIf DelGdimen < 0 Then
                Z = Z1
            End If
        End If

    'Now that we have Z, we can estimate partial molar fugacity for each component
    ReDim lnphiVArray(Nc)
    ReDim FugacityV(Nc)

        For i = 0 To Nc
        yiaij = 0
                        'Calculating yiaij for estimation of lnphi Array (this is required in ln phi formula)
                        For j = 0 To Nc
                            yiaij = yiaij + ZiArray(j) * aijArray(i, j)
                        Next j

            lnphiVArray(i) = (((biArray(i) / bmix) * (Z - 1)) - (WorksheetFunction.Ln((Z - ((bmix * P) / (R * T))))) - (((amix / (((8) ^ 0.5) * bmix * R * T))) * (((2 * yiaij) / amix) - (biArray(i) / bmix)) * (WorksheetFunction.Ln(((Z + (1 + ((2) ^ 0.5)) * ((bmix * P) / (R * T))) / (Z + (1 - ((2) ^ 0.5)) * ((bmix * P) / (R * T))))))))
            FugacityV(i) = Exp(lnphiVArray(i)) * P * ZiArray(i)
        Next i

'Re-writing ZiArray with original feed composition -  Ensuring data consistency
For i = 0 To Nc
Range("SATableZiHead").Select
ZiArray(i) = ActiveCell.Offset(i + 1, 0).Value
Next i

        '*************************************************************************************************************************'
        '**************************************This is step 6 of algorithm of 2 phase PT Flash************************************
        '*************************************************************************************************************************'


For i = 0 To Nc
    error = Abs(WorksheetFunction.Ln(PhaseXiComposition(i)) + lnphiLArray(i) - WorksheetFunction.Ln(PhaseYiComposition(i)) - lnphiVArray(i))
            '*****check code***********
            'Range("H9").Select
            'ActiveCell.Offset(i, 0).Value = error
            '*****end check code*************
    ErrorArrayFlash(iteration) = error
    If error > Threshold And iteration < Range("SAOnePhaseMaxIteration").Value Then
        GoTo Step7
    End If
Next i


If iteration > Range("SAOnePhaseMaxIteration").Value Or iteration = Range("SAOnePhaseMaxIteration").Value Then
    Answer = MsgBox("Max iteration reached before solution could converge. Do you want to increase iteration limit?", vbYesNo + vbExclamation, "Max Iteration Reached!")
        If Answer = vbYes Then
            Range("SAOnePhaseMaxIteration").Value = InputBox("Enter maximum iteration limit", "Iteration Limit")
            GoTo Start
        Else
        End
        End If
ElseIf Bv > 1 Or Bv < 0 Then
    MsgBox "Either Input feed is stable or Trivial Solution acheived. Phase compositions will not be calculated. ", 16, "Warning!"
    End
Else
    'copying phase compositions to excel table
    For i = 0 To Nc
        Range("SATableXiHead").Select
        ActiveCell.Offset(i + 1, 0).Value = PhaseXiComposition(i)
    Next i

    For i = 0 To Nc
        Range("SATableYiHead").Select
        ActiveCell.Offset(i + 1, 0).Value = PhaseYiComposition(i)
    Next i
        'creating error table to check accuracy
            For i = 0 To iteration
                Range("SATableErrorPTFlashHead").Select
                ActiveCell.Offset(i + 1, 0).Value = ErrorArrayFlash(i)
            Next i
    Range("SATableZiHead").Select
    MsgBox "Input feed is not stable! Two Phase compositions are calculated. ", 64, "Phase Split!"
    End
End If


        '*************************************************************************************************************************'
        '**************************************This is step 7 of algorithm of 2 phase PT Flash************************************
        '*************************************************************************************************************************'

Step7:
'Updating Ki value to re-run
ReDim KiArray(Nc)
For i = 0 To Nc
    KiArray(i) = Exp(lnphiLArray(i) - lnphiVArray(i))
    
Next i
GoTo Step2


End Sub




