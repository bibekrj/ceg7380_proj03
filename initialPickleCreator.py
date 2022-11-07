import pickle

distance = 807137
a  = [i for i in range(1, 824)]
ofile = open('initialGuess.pickle', 'wb')
pickle.dump(distance,ofile)
pickle.dump(a, ofile)
ofile.close()
