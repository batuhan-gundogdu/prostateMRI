import numpy as np
import itertools

eps = 1e-7

def calc_mean_adc(Sb, S0, bval):

    """ 
    This function calculates the ADC map with the high-b image 
    and the B0 image

    """
    adc = np.zeros((S0.shape))     
    adc = -np.log(Sb/(S0 + eps) + eps)/(bval)
    return adc*1000

def onehot(x):
    _max = np.argmax(x)
    a = np.zeros_like(x)
    a[_max] = 1
    return a

def calc_adc_erd(Sb_acq, S0, _slices, b_value=1500, noise_std=0.5):
    c = 1.1 if b_value==1500 else 1.4
    eps = 1e-7
    mean_image = np.zeros((S0.shape))
    noise_level = noise_std/np.sqrt(2-np.pi/2)

    for _slice in _slices:
        for i in range(S0.shape[0]):
            for j in range(S0.shape[1]):
                x = Sb_acq[i, j, _slice, :]
                b_zero = S0[i, j, _slice]
                if np.mean(x)>2*noise_level:
                    adc = -1000*np.log(np.mean(x)/b_zero)/b_value
                    temp = 25*np.tanh(10*(adc-c))+25.5
                    try:
                        x = x.astype(np.float64)
                        a = np.exp(x/temp)/np.sum(np.exp(x/temp))
                    except RuntimeWarning:
                        a = onehot(x)
                    y = np.sum(a*x)
                    mean_image[i,j, _slice] = y
                else:
                    mean_image[i,j, _slice] = np.mean(x)

    return calc_mean_adc(mean_image, S0, b_value)

def calc_adc_voxel_lms(b_values, log_signal_values):
    adc = np.polyfit(b_values.flatten()/1000, log_signal_values, 1)
    return -adc[0]



def calc_adc_all_lms_fits(b_values, hybrid_raw, _slice):
    eps = 1e-7
    adc = np.zeros((hybrid_raw[0][0].shape[0], hybrid_raw[0][0].shape[1], hybrid_raw[1][0].shape[3]*hybrid_raw[2][0].shape[3]*hybrid_raw[3][0].shape[3]))
    for i in range(adc.shape[0]):
        for j in range(adc.shape[1]):
            #calculate all combinations for a given voxel
            b0 = [[b_values[0], np.log(hybrid_raw[0][0][i, j, _slice] + eps)]]
            b1 = [[b_values[1], np.log(x + eps)] for x in hybrid_raw[1][0][i, j, _slice,:]]
            b2 = [[b_values[2], np.log(x + eps)] for x in hybrid_raw[2][0][i, j, _slice,:]]
            b3 = [[b_values[3], np.log(x + eps)] for x in hybrid_raw[3][0][i, j, _slice,:]]
            all_bs = [b0, b1, b2, b3]
            combs = np.asarray(list(itertools.product(*all_bs)))
            adc[i,j] = [calc_adc_voxel_lms(np.transpose(comb)[0], np.transpose(comb)[1]) for comb in combs]
    return adc

def calc_adc_all_acq(Sb_acq, S0, b_value=1500):
    """ 
    This function calculates the ADC of each acquisition

    """
    adc = np.zeros((Sb_acq.shape))
    
    for acq in range(Sb_acq.shape[3]):
        adc[:, :, :, acq] = -np.log((Sb_acq[:, :, :, acq]/S0))/b_value

    return adc*1000
'''

def calc_sb_s0(high_b_img, low_b_img):

    """ 
    This function calculates the SB/S0 variation as a result of
    high b signal variation

    """
    if not len(high_b_img.shape) == len(low_b_img.shape):
        low_b_img = np.expand_dims(low_b_img,-1)
    sb_s0 = np.zeros((high_b_img.shape[0],
                    high_b_img.shape[1],
                    high_b_img.shape[2],
                    high_b_img.shape[3]*low_b_img.shape[3]))
    acq = 0
    for acq1 in range(high_b_img.shape[3]):
        for acq2 in range(low_b_img.shape[3]):
            sb_s0[:, :, :, acq] = high_b_img[:, :, :, acq1]/(low_b_img[:, :, :, acq2] + eps)
            acq += 1
    return sb_s0





def calc_adc_mean_lms(_case):
    eps = 1e-7
    def lms_adc(inpt):
        sum_xi_yi = sum([x[0]*x[1] for x in inpt])
        sum_yj = sum([x[1] for x in inpt])
        sum_xi_sum_yj = sum([x[0]*sum_yj for x in inpt])
        sum_x2 = sum([x[0]**2 for x in inpt])
        sum_x = sum([x[0] for x in inpt])
        adc = -(len(inpt)*sum_xi_yi - sum_xi_sum_yj)/(len(inpt)*sum_x2 - sum_x**2 )*1000
        return adc
    adc = np.zeros((_case.b0.shape))
    for i in range(_case.b0.shape[0]):
        for j in range(_case.b0.shape[1]):
            _slice = _case.cancer_slice
            #calculate all combinations for a given voxel
            b0 = [[_case.b[0], np.log(_case.b0[i, j, _slice] + eps)]]
            b1 = [[_case.b[1], np.log(np.mean(_case.b1[i, j, _slice,:]) + eps)]]
            b2 = [[_case.b[2], np.log(np.mean(_case.b2[i, j, _slice,:]) + eps)]]
            b3 = [[_case.b[3], np.log(np.mean(_case.b3[i, j, _slice,:]) + eps)]]
            all_bs = [b0, b1, b2, b3]
            combs = list(itertools.product(*all_bs))
            adc[i, j , _slice] = lms_adc(combs[0])
    return adc

def calc_ADC_slice(bvalues, slicedata):
    min_adc = 0
    max_adc = 3.0
    eps = 1e-7
    numrows, numcols, numbvalues = slicedata.shape
    adc_map = np.zeros((numrows, numcols))
    for row in range(numrows):
        for col in range(numcols):
            ydata = np.squeeze(slicedata[row,col,:])
            adc = np.polyfit(bvalues.flatten()/1000, np.log(ydata + eps), 1)
            adc = -adc[0]
            adc_map[row, col] =  max(min(adc, max_adc), min_adc)
    return adc_map
'''

