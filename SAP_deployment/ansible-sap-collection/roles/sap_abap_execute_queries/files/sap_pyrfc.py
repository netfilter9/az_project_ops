#!/usr/bin/python3
import json
from ansible.module_utils.basic import AnsibleModule
import re
import sys
from pyrfc import Connection
import traceback

def main():
    try:
        # Structure of Output dictionary
        OUTPUT_DICT = {'OUTPUT':{'STATUS':'STARTED','STEPS':[],'ERROR':'','RESULT':''}}
        # Ansible object with parameters
        module = AnsibleModule(
            argument_spec = dict(
                hostname = dict(required=True, type='str'),
                username = dict(required=True, type='str'),
                password = dict(required=True, type='str', no_log=True),
                instance = dict(required=True, type='str'),
                client = dict(required=True, type='str'),
                group = dict(required=True, type='str'),
                abappath = dict(required=True, type='str'),
                abapscript = dict(required=True, type='str'),
                outputspath = dict(required=True, type='str'),
                inputparams = dict(required=True, type='str'),
            )
        )

        hostname = module.params['hostname']
        username = module.params['username']
        password = module.params['password']
        instance = module.params['instance']
        client = module.params['client']
        group = module.params['group']
        abappath = module.params['abappath']
        abapscript = module.params['abapscript']
        outputspath = module.params['outputspath']
        #outputspath = '/Migrate_NWO_TIO/EXPORT/'
        inputparams = module.params['inputparams']

        # Establishing Connection with RFC module using above created required parameter objects
        if group == '_NULL':
            conn = Connection(user=username, passwd=password, ashost=hostname, sysnr=instance, client=client)
        else:
            conn = Connection(user=username, passwd=password, mshost=hostname, msserv=instance, client=client, group=group )


        data = inputparams
        abap_code = []
        abap_input = []

        # Reading Abap Code
        with open(abappath+"//"+abapscript, "r") as abap_code_file:
            my_list = abap_code_file.read().splitlines()
            for line in my_list:
                abap_line = {'LINE': line}
                abap_code.append(abap_line)
        
        # This code is build for single abap script's input (Example 'EXPORT'), but can handle multiple parameters separated by ","
        inputparams = inputparams.split(',')
        data = inputparams

        final_parameters = ''
        if len(inputparams) < 1:
            pass
        else:
            for i in range(len(inputparams)):
                element_list = re.split('[:]+', inputparams[i])
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
        data = abap_input

        # return item from next line of code will be in dictionary format
        RESULT = conn.call('ZBASIS_RFC_ACCWRAPPER', IS_PROGRAM_LINES=abap_code, IS_INPUT=abap_input)

        # Started parsing the return data
        data = RESULT['ES_OUTPUT']
        if RESULT['ES_OUTPUT'] == []:
            raise Exception('No output received from SAP. Likely cause, can be of not passing correct parameters.')
        else:
            STATEMENT_TAKEN = False
            OUTPUT_DICT_INNER = {}
            DATA_DICT = {}
            ABAP_RECORDS_LIST = []
            OUTPUT_LIST = []
            COLUMN_TAKEN = False
            DATA_TAKEN = False
            IS_TREE = False
            IS_TABLE = False
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


            for i in range(len(RESULT['ES_OUTPUT'])):
                row = list(RESULT['ES_OUTPUT'][i].values())[0]
                tree_statement = row.split('|')
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
                            STATEMENT_TAKEN = True
                            COLUMN_TAKEN = False
                        else:
                            if COLUMN_TAKEN == False:
                                SEPARATED_COLUMNS = row.split('|')
                                #print(len(SEPARATED_COLUMNS))
                                print("-----------",SEPARATED_COLUMNS)
                                COLUMN_TAKEN = True
                                if len(SEPARATED_COLUMNS) == 1:
                                    ABAP_RECORDS_DICT = {}
                                    ABAP_RECORDS_DICT.update({'RESULT':SEPARATED_COLUMNS[0]})
                                    ABAP_RECORDS_LIST.append(ABAP_RECORDS_DICT)
                            elif len(SEPARATED_COLUMNS) > 1:
                                ABAP_RECORDS_DICT = {}
                                SEPARATED_RECORDS = row.split('|')
                                print(len(SEPARATED_RECORDS), SEPARATED_RECORDS)
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


            OUTPUT_DICT_INNER.update({'OUTPUT':OUTPUT_LIST})

        OUTPUT_DICT['OUTPUT']['STATUS'] = 'SUCCESS'
        OUTPUT_DICT['OUTPUT']['RESULT'] = OUTPUT_DICT_INNER

        data = OUTPUT_DICT

        # Closing the connection
        conn.close()

        #fo = open(outputspath + abapscript.split(".")[0]+".json", "w")
        fo = open(outputspath + abapscript.split(".")[0]+".json", "w")
        fo.write(json.dumps(OUTPUT_DICT['OUTPUT']['RESULT']))
        fo.close()

        # Returning the output in Ansible standard returned format if everything run successfully.
        module.exit_json(changed=True, success='True', msg=data)
    except Exception as exceptn:
        OUTPUT_DICT['OUTPUT']['STATUS'] = 'FAILED'
        OUTPUT_DICT['OUTPUT']['ERROR'] = str(traceback.format_exc())
        data = OUTPUT_DICT
        # Returning the error in Ansible standard returned format.
        module.fail_json(msg=data)

if __name__ == '__main__':
    main()
