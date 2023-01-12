import re
import numpy as np

def three_compartment_fit(M, D_ep, D_lu, D_st, T2_ep, T2_lu, T2_st, V_ep, V_st):
    """
    
    Three-compartment fit for Hybrid estimation
    
    """
    b, TE = M
    S_ep = V_ep*np.exp(-b/1000*D_ep)*np.exp(-TE/T2_ep)
    S_st = V_st*np.exp(-b/1000*D_st)*np.exp(-TE/T2_st)
    S_lu =(1 - V_ep - V_st)*np.exp(-b/1000*D_lu)*np.exp(-TE/T2_lu)
    
    return S_ep + S_st + S_lu

def ReadParameterFile(inFilespec):
    """
    Reads the given parameter file, where each parameter specification consists
    of a parameter name (string), followed by one or more whitespace characters,
    and the parameter value.  Any line starting with '%' or '#' is ignored as a
    comment.
    Returns a dictionary where the keys are the parameter names and the values are 
    the parameter values.  Each are trimmed strings.
    """
    # Create empty map to fill with parameters.
    parameterMap = dict()
    # Open the file and loop through the lines.
    with open(inFilespec) as spec_file:
        for line in spec_file:
            #If line has no non-whitespace characters, go to the next line.
            if not len(re.findall(r'\S', line)):
                continue

            # If line starts with "#" or "%" (after possible initial whitespace), go 
            # to the next line.
            if len(re.findall(r'^\s*\#', line)) or len(re.findall(r'^\s*\%', line)):
                continue
            # If line consists only of one string, then we regard as a parameter with
            # an empty string as its value.
            m = re.findall(r'\w+', line)
            if len(m) == 1:
                #Set the parameter in the parameterMap(parameterName) = ''
                parameterMap[m[0]] = ''
            elif len(m) == 2:
                #We should be able to find a parameter and a value.
                parameterMap[m[0]] = m[1]
            elif len(m)>2:
                print(f"Incorrect form of paramter, should be in form param_name : parameter {line}")
                return False
    return parameterMap

def ReadAppParams(paramFilespec, shouldReadDICOMParams, caseNameForSubstitution):
    """
    Input:
    
    paramFilespec : address of the Params.txt
    shouldReadDICOMParams: True/False
    caseNameForSubstitution: str
    
    Output : 
    
    [shouldWriteExamMetadataFile, 
    t2WindowingCenterAdjustment, 
    t2WindowingWidthAdjustment, 
    outDICOMPatientFamilyName, 
    outDICOMPatientGivenName, 
    outDICOMPatientID,
    outDICOMStudyNumber,
    outDICOMStudyDate] 
    """
    #Read the parameter file, getting a map container of parameter values.
    params = ReadParameterFile(paramFilespec);

    # Check whether all needed parameters are present.  If shouldReadDICOMParams is true,
    # then the DICOM parameters are required as well.  
    neededParamNames = ['shouldWriteExamMetadataFile',
                         't2WindowingCenterAdjustment',
                         't2WindowingWidthAdjustment']
    if shouldReadDICOMParams:
        neededParamNames += ['outDICOMPatientFamilyName',
                             'outDICOMPatientGivenName',
                             'outDICOMPatientID',
                             'outDICOMStudyNumber', 
                             'outDICOMStudyDate']

    # Loop through each needed parameter, make sure it's a key in params.
    for paramName in neededParamNames:
        if not paramName in params.keys():
            print(f'In parameter file, did not find required parameter {paramName}')
            return False
    # Collect each of the needed parameters, making sure that they are of the
    # expected format and range.
    try:
        shouldWriteExamMetadataFile = int(params['shouldWriteExamMetadataFile'])
        if (shouldWriteExamMetadataFile !=0 and shouldWriteExamMetadataFile!=1):
            print(f"""In parameter file, parameter "shouldWritExamMetadataFile" should have
            value 0 or 1, but found {params['shouldWriteExamMetadataFile']}.""")
            return False
    except:
        print(f"""In parameter file, parameter "shouldWritExamMetadataFile" should have
            value 0 or 1, but found {params['shouldWriteExamMetadataFile']}.""")
        return False
    try:
        t2WindowingCenterAdjustment = int(params['t2WindowingCenterAdjustment'])
    except:
        print(f"""In parameter file, parameter "t2WindowingCenterAdjustment" should be a number,
        but found {params['t2WindowingCenterAdjustment']}.""")
        return False
    try:
        t2WindowingWidthAdjustment = int(params['t2WindowingWidthAdjustment'])
    except:
        print(f"""In parameter file, parameter "t2WindowingWidthAdjustment" should be a number,
        but found {params['t2WindowingWidthAdjustment']}.""")
        return False
    if shouldReadDICOMParams:
      # Loop through each DICOM parameter while it's still in the map, and
      # replace any instance of __CASENAME__ with the caseNameForSubstitution
      # that was passed in.
      dicomParamNames = ['outDICOMPatientFamilyName',
                         'outDICOMPatientGivenName',
                         'outDICOMPatientID',
                         'outDICOMStudyNumber',
                         'outDICOMStudyDate']
    for paramName in dicomParamNames:
        params[paramName] = re.sub('__CASENAME__', caseNameForSubstitution, params[paramName])

    outDICOMPatientFamilyName = params['outDICOMPatientFamilyName']
    outDICOMPatientGivenName = params['outDICOMPatientGivenName']
    outDICOMPatientID = params['outDICOMPatientID']
    outDICOMStudyNumber = params['outDICOMStudyNumber']
    outDICOMStudyDate = params['outDICOMStudyDate']

    return  [shouldWriteExamMetadataFile,
             t2WindowingCenterAdjustment, 
             t2WindowingWidthAdjustment, 
             outDICOMPatientFamilyName, 
             outDICOMPatientGivenName, 
             outDICOMPatientID,
             outDICOMStudyNumber,
             outDICOMStudyDate]