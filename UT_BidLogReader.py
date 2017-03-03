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

DUMMY_CSV_FULL_PATH = 'C:\Users\didac\Documents\SSE\Web_Economics\Coursework\Dataset\dummy_validation.csv'
BID_LOG_EXPECTED = [{'click':'0', 'weekday':'5', 'hour':'14', 'bidid':'91c6a6b9e90c0f54d3230815a5a3e22e', 'logtype': '1', 'userid': 'u_Vhk7C5STO8TZ3s8', 'useragent': 'windows_ie', 'IP': '14.122.240.*', 'region': '216', 'city': '232', 'adexchange': '1', 'domain': 'trqRTJ27Pea7gspy', 'url': 'b3f4c620ae8d3df230fca2fbed50d247', 'urlid': 'null', 'slotid': 'mm_34061467_3440569_11228047', 'slotwidth': '300', 'slotheight': '250', 'slotvisibility': '0', 'slotformat': '1', 'slotprice': '0', 'creative': '449a22cd91d9042eda3d3a1b89a22ea8', 'bidprice': '227', 'payprice': '102', 'keypage': '0f951a030abdaedd733ee8d114ce2944', 'advertiser': '3427', 'usertag': '10,006,100,631,005,900,000'},
                    {'click':'0', 'weekday':'3', 'hour':'14', 'bidid':'24b3621ad3b063b6c09c541781d534b3', 'logtype': '1', 'userid': 'u_DANDbCAksMy', 'useragent': 'android_safari', 'IP': '116.22.55.*', 'region': '216', 'city': '217', 'adexchange': 'null', 'domain': 'null', 'url': 'null', 'urlid': 'null', 'slotid': '1', 'slotwidth': '320', 'slotheight': '50', 'slotvisibility': 'FirstView', 'slotformat': 'Na', 'slotprice': '118', 'creative': '11908', 'bidprice': '277', 'payprice': '118', 'keypage': 'null', 'advertiser': '2997', 'usertag': 'null'}]

def main():
    bid_log_reader = BidLogReader(DUMMY_CSV_FULL_PATH)
    bid_log_result = bid_log_reader.GetBidLog()
    for row_log_ex, row_log_re in zip(BID_LOG_EXPECTED,bid_log_result):
        for (key_ex, value_ex), (key_res, value_res) in zip(row_log_ex.items(), row_log_re.items()):
            print key_ex + ':' + value_ex
            print key_res + ":" + value_res
            print ""
    assert(BID_LOG_EXPECTED == bid_log_result)
    print 'TEST PASSED'

if __name__ == '__main__':
    main()
