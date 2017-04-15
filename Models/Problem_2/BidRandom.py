from BidLogReader import BidLogReader
from random import randint

VALIDATION_CSV_FULL_PATH = 'dataset/validation.csv'

TRAIN_CSV_FULL_PATH = 'dataset/train.csv'

TEST_CSV_FULL_PATH = 'dataset/test.csv'


def main():
	Randombid(VALIDATION_CSV_FULL_PATH)


def Randombid(csv_path):
	bid_log_reader = BidLogReader(csv_path)
	bid_log_result = bid_log_reader.GetBidLog()

	bidid_list = []

	for row in bid_log_result:
		bidid_list.append({"bidid":row["bidid"], "bidprice": randint(250,350)})

	#for id in bidid_list:
	#	print id 
	return bidid_list

if __name__ == '__main__':
    main()