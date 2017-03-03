#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      didac
#
# Created:     03/03/2017
# Copyright:   (c) didac 2017
# Licence:     <your licence>
#-------------------------------------------------------------------------------


from BidLogReader import BidLogReader

VALIDATION_CSV_FULL_PATH = 'C:\Users\didac\Documents\SSE\Web_Economics\Coursework\Dataset\dummy_validation.csv'
VALIDATION_LOG_EXPECTED = [{'click':'0', 'weekday':'5', 'hour':'14', 'bidid':'91c6a6b9e90c0f54d3230815a5a3e22e', 'logtype': '1', 'userid': 'u_Vhk7C5STO8TZ3s8', 'useragent': 'windows_ie', 'IP': '14.122.240.*', 'region': '216', 'city': '232', 'adexchange': '1', 'domain': 'trqRTJ27Pea7gspy', 'url': 'b3f4c620ae8d3df230fca2fbed50d247', 'urlid': 'null', 'slotid': 'mm_34061467_3440569_11228047', 'slotwidth': '300', 'slotheight': '250', 'slotvisibility': '0', 'slotformat': '1', 'slotprice': '0', 'creative': '449a22cd91d9042eda3d3a1b89a22ea8', 'bidprice': '227', 'payprice': '102', 'keypage': '0f951a030abdaedd733ee8d114ce2944', 'advertiser': '3427', 'usertag': '10,006,100,631,005,900,000'},
                    {'click':'0', 'weekday':'3', 'hour':'14', 'bidid':'24b3621ad3b063b6c09c541781d534b3', 'logtype': '1', 'userid': 'u_DANDbCAksMy', 'useragent': 'android_safari', 'IP': '116.22.55.*', 'region': '216', 'city': '217', 'adexchange': 'null', 'domain': 'null', 'url': 'null', 'urlid': 'null', 'slotid': '1', 'slotwidth': '320', 'slotheight': '50', 'slotvisibility': 'FirstView', 'slotformat': 'Na', 'slotprice': '118', 'creative': '11908', 'bidprice': '277', 'payprice': '118', 'keypage': 'null', 'advertiser': '2997', 'usertag': 'null'}]

TEST_CSV_FULL_PATH = 'C:\Users\didac\Documents\SSE\Web_Economics\Coursework\Dataset\dummy_test.csv'
TEST_LOG_EXPECTED = [{'weekday':'0', 'hour':'17', 'bidid':'fe2e06dff1dfd227471fd1ca717888ac', 'logtype': '1', 'userid': 'u_VhkRLiMQL6dVJBn', 'useragent': 'windows_chrome', 'IP': '117.82.151.*', 'region': '80', 'city': '85', 'adexchange': '1', 'domain': 'trqRTuxJMT27gspy', 'url': '71c15dcd8195bfb403bf5c2ecd863f22', 'urlid': 'null', 'slotid': 'mm_10032134_3463115_11268126', 'slotwidth': '300', 'slotheight': '250', 'slotvisibility': '1', 'slotformat': '1', 'slotprice': '0', 'creative': '00fccc64a1ee2809348509b7ac2a97a5', 'keypage': 'b2e35064f3549d447edbbdfb1f707c8c', 'advertiser': '3427', 'usertag': 'null'},
                    {'weekday':'5', 'hour':'22', 'bidid':'92ea762b7b2cfd7aee30a2e88e1f5899', 'logtype': '1', 'userid': 'u_Vh12CnqyP9NOQhl', 'useragent': 'windows_chrome', 'IP': '123.126.88.*', 'region': '1', 'city': '1', 'adexchange': '3', 'domain': '5F1RQS9rg5scFsf', 'url': '67e50710863beca404f447310a5bea39', 'urlid': 'null', 'slotid': 'News_F_Width1', 'slotwidth': '1000', 'slotheight': '90', 'slotvisibility': '0', 'slotformat': '0', 'slotprice': '80', 'creative': '832b91d59d0cb5731431653204a76c0e', 'keypage': 'bebefa5efe83beee17a3d245e7c5085b', 'advertiser': '1458', 'usertag': '100061008310110'}]


def main():
    TestBidLogReader(VALIDATION_CSV_FULL_PATH, VALIDATION_LOG_EXPECTED, 'VALIDATION FORMAT')
    TestBidLogReader(TEST_CSV_FULL_PATH, TEST_LOG_EXPECTED, 'TEST FORMAT')

def TestBidLogReader(csv_path, expected_log, test_case_name):
    bid_log_reader = BidLogReader(csv_path)
    bid_log_result = bid_log_reader.GetBidLog()
    if (expected_log == bid_log_result):
        print test_case_name + ' TEST CASE PASSED'
        print ''
    else:
        PrintExpectedLogAgainstResult(expected_log, bid_log_result)
        print test_case_name + ' TEST CASE FAILED'
        print ''

def PrintExpectedLogAgainstResult(expected_log, result_log):
        for row_log_ex, row_log_re in zip(expected_log,result_log):
            for (key_ex, value_ex), (key_res, value_res) in zip(row_log_ex.items(), row_log_re.items()):
                print key_ex + ':' + value_ex
                print key_res + ":" + value_res
                print ""

if __name__ == '__main__':
    main()
