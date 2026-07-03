"""
# Accenture All Rights Reserved - 2019                                #
# This work should not be DISTRIBUTED or MODIFIED without written     #
# permission from Accenture.                                          #
#                                                                     #
# Unless required by applicable law or agreed to in writing, this     #
# work is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR      #
# CONDITIONS OF ANY KIND, either express or implied.                  #
#                                                                     #
# Contacts: g.n.singh@accenture.com, s.b.kumar.banerjee@accenture.com #
"""

import argparse                  # for taking user input
import copy
import re                        # for separating elements present in single string
import json                      # converting dictionary into a JSON format for UI team
import sys
from pyrfc import Connection     # for establishing connection with SAP
from collections import OrderedDict
import ast
import traceback
import logging
import os

class LockDisplay():
    """Complete functionality of this file is written inside this class.
    Except converting parsed data in json format.
    """
    def __init__(self):
        #establishing connection with SAP
        try:
            arguments_dict = json.loads(sys.argv[1], object_pairs_hook=OrderedDict)
            arguments_keys = list(arguments_dict.keys())
            arguments_values = list(arguments_dict.values())
            userName_index = arguments_keys.index('userName')
            userName = arguments_values[userName_index]
            password_index = arguments_keys.index('password')
            password = arguments_values[password_index]
            hostname_index = arguments_keys.index('hostName')
            hostName = arguments_values[hostname_index]
            sysnr_index = arguments_keys.index('instanceNumber')
            sysnr1 = arguments_values[sysnr_index]
            client_index = arguments_keys.index('client')
            client1 = arguments_values[client_index]
            group_index = arguments_keys.index('group')
            group1 = arguments_values[group_index]
            abapPath_index = arguments_keys.index('path')
            abapPath = arguments_values[abapPath_index]
            self.inputParams=["EXPORT"]
            self.abapScripts = []
            #self.abapScripts=["ZCC_SM51_EXP_INSTANCES.txt","ZCC_ST22_EXP_DUMPS_PERDAY.txt","ZCC_SM51_EXP_SNC_STATUS.txt","ZCC_SLDCHECK_CHK_SLDCONNECTION.txt"]

            self.abapScripts=["ZCC_SM51_EXP_KERNEL_PATCH.txt","ZCC_ST22_EXP_DUMPS_PERDAY.txt","ZCC_SICK_CHK_SAPACCESS.txt","ZCC_SM51_EXP_INSTANCES.txt","ZCC_SLICENSE_EXP_SETTINGS_LIC.txt","ZCC_SM51_EXP_SNC_STATUS.txt","ZCC_SLDCHECK_CHK_SLDCONNECTION.txt"]


            if group1 == '_NULL':
                self.conn = Connection(user=userName, passwd=password,
                                       ashost=hostName, sysnr=sysnr1,
                                       client=client1)
            else:
                sysnr1 = '36' + str(sysnr1)
                self.conn = Connection(user=userName, passwd=password,
                                       mshost=hostName, msserv=sysnr1,
                                       client=client1, group=group1 )
            self.dir_path = abapPath
            #self.file1 = abapScript
            for handler in logging.root.handlers[:]:
                logging.root.removeHandler(handler)
            logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(levelname)s -%(message)s'
                    ,datefmt ='%d-%b-%y %H:%M:%S'
                    ,filename = os.path.join(os.getcwd(),"sap_pyrfc_log.txt"),filemode='a')
            self.logger = logging
        except Exception as exceptn:
            print(exceptn)
            sys.exit(1)

    def modify_output(self,output,script):
        mod_op=OrderedDict()
        mod_op={"Task":"","SID":"","Current value":"","Recommendation":""}
        mod_op['Task']=output[0]['TITLE']
        data_val=output[0]['DATA'][0]
        if data_val.get('System ID',""):
            mod_op['SID']=data_val['System ID']
        else:
            mod_op['SID']="NA"
        if script.upper() == 'ZCC_SM51_EXP_KERNEL_PATCH.TXT':
            rls=data_val["Kernel Release"]
            patch=int(data_val["Kernel Patch level"])
            mod_op['Current value']="Kernel Release: %s\n Kernel Patch level:%s" %(rls,patch)
            msg="No recommendations"
            if rls:
                if int(rls) > 722 and int(rls) < 749:
                    if patch < 1100:
                        msg="Update with latest available patch,1100"
                elif int(rls) >=749 and int(rls) < 753:
                    if patch < 1000:
                        msg ="Update with latest available patch,1000"
                elif int(rls) >=753 and int(rls) < 777:
                    if patch < 801:
                        msg="Update with latest available patch,801"
                elif int(rls) >=777 and int(rls) < 781:
                    if patch < 400:
                        msg = "Update with latest available patch,400"
                elif int(rls) >=781:
                    if patch < 200:
                        msg = "Update with latest available patch,200"
            mod_op['Recommendation']=msg
        elif script.upper() == "ZCC_SLICENSE_EXP_SETTINGS_LIC.TXT":
            note = data_val.get('Note on validity', "")
            type = data_val.get('Type',"")
            curval=""
            msg1=""
            if type:
                hw = data_val.get('Hardware key',"")
                curval="Type: %s \nHardware key: %s\n "%(type,hw)
            if note.lower() != 'license check is ok' and 'valid' not in note.lower():
                msg="Some of the installed licenses are not valid, please check transaction SLICENSE"
            else:
                msg = "Check OK"
            if type:
                if type.lower() == 'temp':
                    msg1="Temporary license detected, Please update the license"
            if msg1:
                finmsg=msg+"\n"+msg1
            else:
                finmsg=msg
            if curval:
                curval=curval+"Note on validity :%s" %note
            mod_op['Recommendation'] = finmsg
            mod_op['Current value']=curval
        elif script.upper() == "ZCC_SICK_CHK_SAPACCESS.TXT":
            mod_op['SID']=output[0]['TITLE']
            msg = data_val.get('SAP System Check',"")
            mod_op['Task']="SAP System Check"
            mod_op['Current value'] = "%s" %msg
        elif script.upper() == "ZCC_SM51_EXP_INSTANCES.TXT":
            curval=output[0]['DATA']
            curmsg=""
            rec=""
            for each in curval:
                inst = ""
                for key,val in each.items():
                    if key.lower() != 'system id':
                        curmsg = curmsg + "%s : %s ; " % (key, val)
                        if key.lower() == 'applicationserverinstance':
                            inst=val
                        if key.lower() == 'state':
                            if not val.lower() == 'active':
                                rec = rec + "Please check the instance '%s' which is in passive status\n" % inst
                curmsg=curmsg+"\n"
            mod_op['Current value'] =curmsg
            if rec:
                mod_op['Recommendation']=rec
            else:
                mod_op['Recommendation']="Please check  for instance in Passsive state"
        elif script.upper() == "ZCC_ST22_EXP_DUMPS_PERDAY.TXT":
            curval = output[0]['DATA']
            curmsg = ""
            for each in curval:
                for key, val in each.items():
                    if key.lower() != 'system id':
                        curmsg = curmsg + "%s : %s ; " % (key, val)
                curmsg = curmsg + "\n"
            mod_op['Current value'] = curmsg
            mod_op['Recommendation']="Please check ST22 for frequently occuring dumps"
        elif script.upper() == "ZCC_SM51_EXP_SNC_STATUS.TXT":
            curval = output[0]['DATA']
            curmsg = ""
            rec = ""
            for each in curval:
                inst = ""
                for key, val in each.items():
                    if key.lower() != 'system id':
                        curmsg = curmsg + "%s : %s ; " % (key, val)
                        if key.lower() == 'applicationserverinstance':
                            inst = val
                        if key.lower() == 'state':
                            if not val.lower() == 'active':
                                rec = rec + "Please check the instance '%s' which is in passive status\n" % inst
                curmsg = curmsg + "\n"
            mod_op['Current value'] = curmsg
            if rec:
                mod_op['Recommendation'] = rec
            else:
                mod_op['Recommendation']="Please check if all the configured instances have snc status active"
        elif script.upper() == "ZCC_SLDCHECK_CHK_SLDCONNECTION.TXT" :
            curval=output[0]['DATA'][0]
            curmsg=curval.get("Check status","")
            mod_op['Current value']=curmsg
            rec=""
            if "connection to sld does not work" in curmsg.lower():
                rec= "Please check RZ70 and SLDAPICUST"
            mod_op['Recommendation'] = rec
        return mod_op
    def fetch_data(self):
        """SAP code is passed to the RFC module(ZBASIS_RFC_WRAPPER) which return unparsed data.
		Uses files I/O to fetch ABAP code.
        """
        abap_code = []
        abap_input = []
        # Converting file data(abap code) into list 'abap_code'
        try:
            #self.logger.info("Start fetching data")
            lst_op=[]
            for each_script in self.abapScripts :
                abap_code = []
                abap_input = []
                with open(os.path.join(self.dir_path,each_script), "r") as abap_code_file:
                    my_list = abap_code_file.read().splitlines()
                    for line in my_list:
                        abap_line = {'LINE': line}
                        abap_code.append(abap_line)
                #print('Code:', abap_code )
                #All the arguments passed
                final_parameters = ''
                if len(self.inputParams) < 1:
                    pass
                else:
                    for i in range(len(self.inputParams)):
                        #print("in loop each :",self.inputParams[i])
                        element_list = re.split('[:]+', self.inputParams[i])
                        #print(self.inputParams[i])
                        if len(element_list) > 1:
                            multi_var = element_list[0]
                            for j in range(len(element_list)-1):
                                multi_var = multi_var + ',' + element_list[j+1]
                            final_parameters = final_parameters + multi_var + '|'
                        else:
                            if element_list[0] == '_NULL':
                                null_element = ''
                                final_parameters = final_parameters + null_element + '|'
                            else:
                                final_parameters = final_parameters + element_list[0] + '|'
                    final_parameters = final_parameters[0:-1]
                abap_line = {'WA': final_parameters}
                abap_input.append(abap_line)
                #return item from next line of code will be in dictionary format
                RESULT = self.conn.call('ZBASIS_RFC_ACCWRAPPER', IS_PROGRAM_LINES=abap_code, IS_INPUT=abap_input)
                #self.conn.close()


                ABAP_RECORDS = []
                #data = str(len(RESULT['ES_OUTPUT']))
                if RESULT['ES_OUTPUT'] == []:
                    continue
                    #self.logger.info("No output received from SAP, can't proceed.")
                    #raise Exception('No output received from SAP. Likely cause, can be of not passing correct parameters.')
                else:
                    #self.logger.info("Started processing ABAP Script : %s" %(self.file1))
                    STATEMENT_TAKEN = False
                    OUTPUT_DICT_INNER = {}
                    DATA_DICT = {}
                    ABAP_RECORDS_LIST = []
                    OUTPUT_LIST = []
                    COLUMN_TAKEN = False
                    DATA_TAKEN = False
                    IS_TABLE = False
                    IS_TREE = False
                    is_certificate = False
                    last_level = 0
                    level = 0
                    first_level_list = []
                    first_level_count = -1
                    second_level_count = -1
                    third_level_count = -1
                    fourth_level_count = -1
                    certificate_count = 0
                    certificate = ''

                    tot_len=len(RESULT['ES_OUTPUT'])
                    start=0
                    end=tot_len
                    for i in range(start,end):
                        #print("rec no :",i)
                        row = list(RESULT['ES_OUTPUT'][i].values())[0]
                        newrow = re.findall(r'\$(.*?)\$', row)
                        copy_row = copy.deepcopy(row)
                        if newrow:
                            copy_row = re.sub(r'\$(.*?)\$', "~",copy_row)
                            ntree=copy_row.split('|')
                            tree_statement=[]
                            count=0
                            for eachvalues in ntree:
                                if eachvalues == '~':
                                    tree_statement.append(newrow[count])
                                    count +=1
                                else:
                                    tree_statement.append(eachvalues)
                        else:
                            tree_statement = row.split('|')

                        #print(tree_statement)
                        if (len(tree_statement) > 1) and (IS_TREE == False) and (IS_TABLE == False):
                            try:
                                temp = int(tree_statement[1])
                                IS_TREE = True
                            except Exception as ex:
                                pass
                        pass


                        if IS_TREE:
                            last_level = level
                            row = list(RESULT['ES_OUTPUT'][i].values())[0]
                            row_split = row.split('|')
                            row = row_split[0]
                            level = int(row_split[1])
                            if level == 1:
                                same_level_dict = {}
                                same_level_dict.update({row:[]})
                                first_level_list.append(same_level_dict) #[{row:[]}]
                                first_level_count += 1

                            elif level == 2:
                                same_level_dict = {}
                                same_level_dict.update({row:[]})
                                key_one = list(first_level_list[first_level_count].keys())[0]
                                if last_level <= level:
                                    first_level_list[first_level_count][key_one].append(same_level_dict)  #[{level1:[{level2:[]}]}]
                                else:
                                    first_level_list[first_level_count][key_one].append(same_level_dict)  #[{level1:[{level2:[]}]}]
                                    third_level_count = -1
                                second_level_count += 1

                            elif level == 3:
                                same_level_dict = {}
                                same_level_dict.update({row:[]})
                                key_one = list(first_level_list[first_level_count].keys())[0]
                                key_two = list(first_level_list[first_level_count][key_one][second_level_count].keys())[0]
                                if last_level <= level:
                                    first_level_list[first_level_count][key_one][second_level_count][key_two].append(same_level_dict)#third_level_list  #[{level1:[{level2:[{level3:[]}]}]}]
                                elif last_level > level:
                                    first_level_list[first_level_count][key_one][second_level_count][key_two].append(same_level_dict)#third_level_list
                                    fourth_level_count = -1
                                third_level_count += 1

                            elif level == 4:
                                same_level_dict = {}
                                same_level_dict.update({row:[]})
                                if last_level <= level:
                                    key_one = list(first_level_list[first_level_count].keys())[0]
                                    key_two = list(first_level_list[first_level_count][key_one][second_level_count].keys())[0]
                                    key_tre = list(first_level_list[first_level_count][key_one][second_level_count][key_two][third_level_count].keys())[0]
                                    first_level_list[first_level_count][key_one][second_level_count][key_two][third_level_count][key_tre].append(same_level_dict)
                                elif last_level > level:
                                    first_level_list[first_level_count][key_one][second_level_count][key_two][third_level_count][key_tre].append(same_level_dict)
                                fourth_level_count += 1
                            pass


                        else:
                            IS_TABLE = True
                            #print('-',row)
                            if row == '':
                                #print('---', row)
                                STATEMENT_TAKEN = False
                                certificate_count = 0
                                if DATA_TAKEN == True:
                                    DATA_DICT.update({'TITLE':STATEMENT})
                                    if ABAP_RECORDS_LIST != []:
                                        DATA_DICT.update({'DATA':ABAP_RECORDS_LIST})
                                    OUTPUT_LIST.append(DATA_DICT)
                                    DATA_DICT = {}
                                    DATA_TAKEN = False
                            elif row == '-----BEGIN CERTIFICATE-----':
                                #print('-----------------------------------------------------------------------')
                                certificate = ''
                                is_certificate = True
                            elif row == '-----END CERTIFICATE-----':
                                #print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@', ABAP_RECORDS_LIST, certificate_count)
                                certificate = '-----BEGIN CERTIFICATE-----\n' + certificate + '\n-----END CERTIFICATE-----'
                                ABAP_RECORDS_LIST[certificate_count-1].update({'CERTIFICATE':certificate})
                                is_certificate = False
                                #print('---###', ABAP_RECORDS_LIST)
                            elif is_certificate:
                                #print('########################################################################', certificate)
                                certificate = certificate + row

                            else:
                                if STATEMENT_TAKEN == False:
                                    DATA_TAKEN = True
                                    ABAP_RECORDS_LIST = []
                                    STATEMENT = row
                                    #print("STATEMENT--",STATEMENT)
                                    STATEMENT_TAKEN = True
                                    COLUMN_TAKEN = False
                                else:
                                    if COLUMN_TAKEN == False:
                                        SEPARATED_COLUMNS = row.split('|')
                                        #print(len(SEPARATED_COLUMNS))
                                        #print("-----------",SEPARATED_COLUMNS)
                                        COLUMN_TAKEN = True
                                        if len(SEPARATED_COLUMNS) == 1:
                                            ABAP_RECORDS_DICT = {}
                                            ABAP_RECORDS_DICT.update({'RESULT':SEPARATED_COLUMNS[0]})
                                            ABAP_RECORDS_LIST.append(ABAP_RECORDS_DICT)
                                    elif len(SEPARATED_COLUMNS) > 1:
                                        ABAP_RECORDS_DICT = {}
                                        #SEPARATED_RECORDS = row.split('|')
                                        SEPARATED_RECORDS = tree_statement

                                        if len(SEPARATED_COLUMNS) != len(SEPARATED_RECORDS):
                                            self.logger.info("Found a difference in header and column values ...")
                                            self.logger.info("Header values are : %s" %(SEPARATED_COLUMNS))

                                            self.logger.info("Column values are : %s " %(SEPARATED_RECORDS))

                                        for j in range(len(SEPARATED_COLUMNS)):
                                            ABAP_RECORDS_DICT.update({SEPARATED_COLUMNS[j]:SEPARATED_RECORDS[j]})
                                        ABAP_RECORDS_LIST.append(ABAP_RECORDS_DICT)
                                        #print('####', ABAP_RECORDS_LIST)
                                        certificate_count += 1
                                    elif len(SEPARATED_COLUMNS) == 1:
                                        element_to_remove = {'RESULT':SEPARATED_COLUMNS[0]}
                                        if element_to_remove in ABAP_RECORDS_LIST:
                                            ABAP_RECORDS_LIST.remove(element_to_remove)
                                        ABAP_RECORDS_DICT = {}
                                        ABAP_RECORDS_DICT.update({SEPARATED_COLUMNS[0]:row})
                                        ABAP_RECORDS_LIST.append(ABAP_RECORDS_DICT)
                    if DATA_TAKEN == True:
                        DATA_DICT.update({'TITLE':STATEMENT})
                        if ABAP_RECORDS_LIST != []:
                            DATA_DICT.update({'DATA':ABAP_RECORDS_LIST})
                        OUTPUT_LIST.append(DATA_DICT)
                    elif IS_TREE:
                        OUTPUT_LIST = first_level_list
                    #OUTPUT_DICT_INNER.update({'OUTPUT':OUTPUT_LIST})

                OUTPUT_DICT=self.modify_output(OUTPUT_LIST,each_script)

                lst_op.append(OUTPUT_DICT)
                #print(lst_op)
            print(json.dumps(lst_op, ensure_ascii=False))
        except Exception as exceptn:
            print('Error -',traceback.format_exc())
            sys.exit(1)


# Creating object of Lock_Display class
LOCK_DISPLAY = LockDisplay()

try:
    ABAP_OUTPUT = LOCK_DISPLAY.fetch_data()
except Exception as exceptn:
    print('Error -', traceback.format_exc())
    sys.exit(1)
