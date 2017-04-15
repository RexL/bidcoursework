from BidLogReader import BidLogReader

VALIDATION_CSV_FULL_PATH = 'dataset/validation.csv'

TRAIN_CSV_FULL_PATH = 'dataset/train.csv'

TEST_CSV_FULL_PATH = 'dataset/test.csv'


def main():
	Constantbid(VALIDATION_CSV_FULL_PATH)


def Constantbid(csv_path, value="300"):
	bid_log_reader = BidLogReader(csv_path)
	bid_log_result = bid_log_reader.GetBidLog()

	bidid_list = []

	for row in bid_log_result:
		bidid_list.append({"bidid":row["bidid"], "bidprice": value})

	#for id in bidid_list:
	#	print id 
	return bidid_list

if __name__ == '__main__':
    main()