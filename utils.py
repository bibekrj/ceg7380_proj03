import pickle
import sys


def pickleReader(fileName):
    rfile = open(fileName, 'rb')
    val1= pickle.load(rfile)
    val = pickle.load(rfile)
    print(val1)
    print(val)
    rfile.close()
    return 0

def pickleCreator(totalDistance, pathway, fileName):
    readyName=fileName+".pickle"
    ofile = open(readyName, 'wb')
    pickle.dump(totalDistance,ofile)
    pickle.dump(pathway, ofile)
    ofile.close()
    return None


if __name__ == '__main__':
    option = int(sys.argv[1])

    if option == 1:
        print('option 1 selected')
        pickleReader(sys.argv[2])
    elif option == 2:
        pickleCreator(sys.argv[2],sys.argv[3],sys.argv[4])
