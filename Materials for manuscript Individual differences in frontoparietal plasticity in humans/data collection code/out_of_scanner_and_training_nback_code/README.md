# N-Back

Original draft by Katrina Simon (last updated June 28, 2018)


### Folders:
* Sounds: where all the sound .wav sounds are located. Both the letter and syllable sounds

* Code: where the actual code to run the paradigm is located. Run_introduction.m is the introduction paradigm, where participants practice both the letter sounds and syllable sounds. Run_preposttest.m is where the preposttest is located. When you start the pretest or posttest function, it will ask you to enter ‘1’ or ‘2’ to indicate whether it is the pretest or the posttest. Run_training.m is for the training session in between the pretest and posttest. 
	Helper functions: all the supporting functions of the code that help run the scripts

* Code_orig: just some extra stuff from when I was first writing the scripts, nothing super necessary or helpful in here

* Data: this is where the data is stored after a participant undergoes the paradigm. The data is stored by whatever you enter as the “participant ID” when the task starts. The data saves as a .mat file, a .csv file, and you can opt to also have a .pdf of a score graph save by changing the value of the variable “do_plot” (in run_introduction, run_preposttest, run_training) to 1. 

* Experiments: text files with the order of the setlists you want to run for the introduction, pretestposttest, etc. 

* Setlist: has the text files with the sequence of sounds. You can change this based on how many hits, misses, false alarms you want

-----
### How to upload the N-back data to REDCap:

Within code/helper_functions, there is a file called csv.m that will create a CSV file- remember to change the name of what you want the CSV to be (line 23). You will need to select the pre and posttest file for the subject you are trying to make a csv for. 


-----
### To administer the study:
Within the GUI: 
Go within code and open up run_introduction, run_preposttest, and run_training.

When you start the task, it will ask for the participant ID, where you will enter ‘BPDXXXX’. You can use ‘junk’ to test the scripts.
