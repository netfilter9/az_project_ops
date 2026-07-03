#!/usr/bin/python3
import ast
import copy
import json
import re
import sys
import traceback
from ansible.module_utils.basic import AnsibleModule
from pyrfc import Connection

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
                sourcevalues = dict(required=True, type='str'),
                targetvalues = dict(required=True, type='str'),
                instancename = dict(required=True, type='str'),
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
        sourcevalues_list = module.params['sourcevalues']
        targetvalues_list = module.params['targetvalues']
        instancename_list = ast.literal_eval(module.params['instancename'])

        source_json_file = open(sourcevalues_list, "r")
        source_json = json.loads(source_json_file.read())
        source_json_file.close()

        target_json_file = open(targetvalues_list, "r")
        target_json = json.loads(target_json_file.read())
        target_json_file.close()

        abap_input = []

        source_empty = False
        target_empty = False

        sourcevalues_list = source_json["OUTPUT"][0]["DATA"]
        targetvalues_list = target_json["OUTPUT"][0]["DATA"]


        #if Source is emplty
        if len(list(sourcevalues_list[0].keys())) < 2:
            source_empty = True

        #if Target is emplty
        if len(list(targetvalues_list[0].keys())) < 2:
            target_empty = True

        #Comparision Started
        if (source_empty == True) and (target_empty == True):
            targetvalues_list2 = []

        elif (source_empty == False) and (target_empty == True):
            targetvalues_list2 = copy.deepcopy(sourcevalues_list)
            for i, _ in enumerate(targetvalues_list2):
                targetvalues_list2[i].update({"ACTION":"I"})

        elif (source_empty == True) and (target_empty == False):
            targetvalues_list2 = copy.deepcopy(targetvalues_list)
            for i, _ in enumerate(targetvalues_list2):
                targetvalues_list2[i].update({"ACTION":"D"})

        else:
            
            targetvalues_list2 = copy.deepcopy(targetvalues_list)
            for i, _ in enumerate(targetvalues_list2):
                targetvalues_list2[i].update({"ACTION":"D"})
            for i, temp_dict_s in enumerate(sourcevalues_list):
                temp_dict = copy.deepcopy(temp_dict_s)
                temp_dict.update({"ACTION":"I"})
                targetvalues_list2.append(temp_dict)

            '''for i, temp_dict_t in enumerate(targetvalues_list2):
                if temp_dict_t["ACTION"] == "I":
                    targetvalues_list2[i]["ApplServer"] = instancename_list[0]
                    targetvalues_list2[i]["ApplicationServer"] = instancename_list[0]'''

        instance_count = 0
        for i, temp_dict_t in enumerate(targetvalues_list2):
            if temp_dict_t["ACTION"] not in  ("D",""):
                targetvalues_list2[i]["ApplServer"] = instancename_list[instance_count]
                targetvalues_list2[i]["ApplicationServer"] = instancename_list[instance_count]
                if (instance_count+1) != len(instancename_list):
                    instance_count = instance_count + 1
                else:
                    instance_count = 0


        abap_code = []

        with open(abappath+"//"+abapscript, "r") as abap_code_file:
            my_list = abap_code_file.read().splitlines()
            for line in my_list:
                abap_line = {'LINE': line}
                abap_code.append(abap_line)

        temp_string = ""
        for key, _ in targetvalues_list2[0].items():
            temp_string = temp_string + "|" + key
        abap_input.append(temp_string[1:])

        for i, dict_ in enumerate(targetvalues_list2):
            temp_string = ""
            for _, value in dict_.items():
                temp_string = temp_string + "|" + value
            abap_input.append(temp_string[1:])


        data = abap_input


        # Establishing Connection with RFC module using above created required parameter objects
        if group == '_NULL':
            conn = Connection(user=username, passwd=password, ashost=hostname, sysnr=instance, client=client)
        else:
            conn = Connection(user=username, passwd=password, mshost=hostname, msserv=instance, client=client, group=group )

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
            for i in range(len(RESULT['ES_OUTPUT'])):
                row = list(RESULT['ES_OUTPUT'][i].values())[0]
                if row == '':
                    STATEMENT_TAKEN = False
                    if DATA_TAKEN == True:
                        DATA_DICT.update({'TITLE':STATEMENT})
                        if ABAP_RECORDS_LIST != []:
                            DATA_DICT.update({'DATA':ABAP_RECORDS_LIST})
                        OUTPUT_LIST.append(DATA_DICT)
                        DATA_DICT = {}
                        DATA_TAKEN = False
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
                            COLUMN_TAKEN = True
                            if len(SEPARATED_COLUMNS) == 1:
                                ABAP_RECORDS_DICT = {}
                                ABAP_RECORDS_DICT.update({'RESULT':SEPARATED_COLUMNS[0]})
                                ABAP_RECORDS_LIST.append(ABAP_RECORDS_DICT)
                        elif len(SEPARATED_COLUMNS) > 1:
                            ABAP_RECORDS_DICT = {}
                            SEPARATED_RECORDS = row.split('|')
                            for j in range(len(SEPARATED_COLUMNS)):
                                ABAP_RECORDS_DICT.update({SEPARATED_COLUMNS[j]:SEPARATED_RECORDS[j]})
                            ABAP_RECORDS_LIST.append(ABAP_RECORDS_DICT)
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


            OUTPUT_DICT_INNER.update({'OUTPUT':OUTPUT_LIST})

        OUTPUT_DICT['OUTPUT']['STATUS'] = 'SUCCESS'
        OUTPUT_DICT['OUTPUT']['RESULT'] = OUTPUT_DICT_INNER

        data = OUTPUT_DICT

        # Closing the connection
        conn.close()

        # Returning the output in Ansible standard returned format if everything run successfully.
        module.exit_json(changed=True, success='True', msg=data)
    except Exception as exceptn:
        OUTPUT_DICT['OUTPUT']['STATUS'] = 'FAILED'
        OUTPUT_DICT['OUTPUT']['ERROR'] = str(traceback.format_exc())
        data = OUTPUT_DICT
        #data = targetvalues_list2
        # Returning the error in Ansible standard returned format.
        module.fail_json(msg=data)

if __name__ == '__main__':
    main()
