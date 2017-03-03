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

DUMMY_CSV_FULL_PATH = 'C:\Users\didac\Documents\SSE\Web_Economics\Coursework\Dataset\dummy_test.csv'
BID_LOG_EXPECTED = [{'click':False, 'weekday':5, 'hour':14, 'bid_id':'91c6a6b9e90c0f54d3230815a5a3e22e', 'log_type': 1, 'user_id': 'u_Vhk7C5STO8TZ3s8', 'user_agent': 'windows_ie', 'ip': '14.122.240.*', 'region': 216, 'city': 232, 'ad_exchange': 1, 'domain': 'trqRTJ27Pea7gspy', 'url': 'b3f4c620ae8d3df230fca2fbed50d247', 'url_id': None, 'slot_id': 'mm_34061467_3440569_11228047', 'slot_width': 300, 'slot_height': 250, 'slot_visibility': '0', 'slot_format': '1', 'slot_price': 0, 'creative': '449a22cd91d9042eda3d3a1b89a22ea8', 'bid_price': 227, 'pay_price': 102, 'key_page': '0f951a030abdaedd733ee8d114ce2944', 'advertiser': 3427, 'user_tag': 10006100631005900000},
                    {'click':False, 'weekday':3, 'hour':14, 'bid_id':'24b3621ad3b063b6c09c541781d534b3', 'log_type': 1, 'user_id': 'u_DANDbCAksMy', 'user_agent': 'android_safari', 'ip': '116.22.55.*', 'region': 216, 'city': 217, 'ad_exchange': None, 'domain': None, 'url': None, 'url_id': None, 'slot_id': '1', 'slot_width': 320, 'slot_height': 50, 'slot_visibility': 'FirstView', 'slot_format': 'Na', 'slot_price': 118, 'creative': '11908', 'bid_price': 277, 'pay_price': 118, 'key_page': None, 'advertiser': 2997, 'user_tag': None}]

def main():
    bid_log_reader = BidLogReader(DUMMY_CSV_FULL_PATH)
    bid_log_obt = bid_log_reader.GetBidLog()
    assert(BID_LOG_EXPECTED == bid_log_obt)
    print 'TEST PASSED'

if __name__ == '__main__':
    main()
