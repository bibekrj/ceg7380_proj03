import pickle
import sys

if __name__ == '__main__':
    fileName = sys.argv[1]

    rfile = open(fileName, 'rb')
    val1= pickle.load(rfile)
    val = pickle.load(rfile)
    print(val1)
    print(val)
    rfile.close()
