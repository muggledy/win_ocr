#!/usr/bin/env python

from aip import AipOcr
import sys, logging, os

log_path = os.path.join(os.path.dirname(__file__), 'baidu_ocr.log')
logging.basicConfig(filename=log_path,\
        level=logging.INFO,\
        format='%(asctime)s %(message)s',\
        datefmt='[%m/%d/%Y %I:%M:%S %p]')

def get_file_content(filePath):
    if not os.path.exists(filePath):
        print(f'Error: {filePath} not exist')
        logging.error(f'path {filePath} not exist')
        return None
    with open(filePath, 'rb') as fp:
        return fp.read()

if __name__ == "__main__":
    assert len(sys.argv) > 1, "baidu_ocr.py no input parameter!"
    """ 你的 APPID AK SK """
    APP_ID = ''
    API_KEY = ''
    SECRET_KEY = ''

    client = AipOcr(APP_ID, API_KEY, SECRET_KEY)
    image = get_file_content(sys.argv[1])
    if image is None:
        exit(0)

    options = {}
    options["language_type"] = "CHN_ENG"
    options["detect_direction"] = "false"
    options["detect_language"] = "true"
    options["probability"] = "false"

    result = client.basicGeneral(image, options)

    if 'error_code' not in result:
        tmp = [item['words'] for item in result['words_result']]
        text = '\n'.join(tmp)
        print(f'百度识别结果：\n{text}')
        with open(f'{sys.argv[1]}.output', 'w') as f:
            f.write(text)
        logging.info(''.join(tmp))
    else:
        print(f"Error: {result['error_msg']}({result['error_code']})")
        logging.error(f"({result['error_code']}) "
                f": {result['error_msg']}")
