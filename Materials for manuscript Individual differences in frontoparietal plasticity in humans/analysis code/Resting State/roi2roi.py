### Written by Anne Park (Changing Brain Lab, UPenn)
### Script designed to use output of run_rsfmri_glm.sh script to perform the correlation between the average time series of two ROIS, iterated over a subject list.
### Required inputs include: a .txt file containing a list of all subjects on separate lines, seed_ts.txt output file from run_rsfmri_glm.sh script


import os
import pandas as pd
import numpy as np

def extract_ts(sub, roi):
    roi_ts_file = os.path.join(preproc_dir, sub, '%s/seed_ts.txt' % roi)
    roi_ts = pd.read_csv(roi_ts_file, header=None, names=[sub])
    return roi_ts

def get_sublist(sublist_file):
    with open(sublist_file, 'r') as f:
        sub_list = f.read().splitlines()
    return sub_list


if __name__ == "__main__":
    from argparse import ArgumentParser, RawTextHelpFormatter
    defstr = ' (default %(default)s)'
    parser = ArgumentParser(description=__doc__,
                            formatter_class=RawTextHelpFormatter)
    parser.add_argument("-d", "--preproc_dir", dest="preproc_dir",
                        help="Directory containing rsfMRI preproc outputs",
                        required=True)
    parser.add_argument("-s", "--sublist_file", dest="sublist_file",
                        help="Subject list file, each subject on a different line",
                        required=True)
    parser.add_argument("-r1", "--roi1", dest="roi1", required=True,
                        help="Name of ROI 1")
    parser.add_argument("-r2", "--roi2", dest="roi2", required=True,
                        help="Name of ROI 2")
    args = parser.parse_args()

    preproc_dir = args.preproc_dir
    sublist_file = args.sublist_file
    roi1 = args.roi1
    roi2 = args.roi2


    sub_list = get_sublist(sublist_file)

    roi1_ts_df = pd.DataFrame()
    roi2_ts_df = pd.DataFrame()

    for sub in sub_list:
        print sub

        roi1_ts = extract_ts(sub, roi1)
        roi1_ts_df = pd.concat([roi1_ts_df, roi1_ts], axis=1)

        roi2_ts = extract_ts(sub, roi2)
        roi2_ts_df = pd.concat([roi2_ts_df, roi2_ts], axis=1)

    corr_df = roi1_ts_df.corrwith(roi2_ts_df)
    r_to_z = np.arctanh(corr_df)


    r_to_z.to_csv('roi2roi_output_%s_%s.csv' % (roi1, roi2))
