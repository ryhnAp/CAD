//in the name of the head of the flight

#include <bits/stdc++.h>

using namespace std;

typedef long long ll;
typedef long double ld;
typedef pair<ll, ll> pll;
typedef pair<int, int> pii;
typedef pair<pll, ll> plll;
typedef pair<pii, int> piii;
typedef pair<pii, pii> pii2;
typedef pair<ll, ll> pll;

const int dx[8] = {1, -1, 0, 0, 1, 1, -1, -1}, dy[8] = {0, 0, 1, -1, 1, -1, 1, -1};
const pair<int, int> POSSIBLE_MOVES[] = 
{
    {-1, 0},
    {0,  1},
    {1,  0},
    {0, -1},
}; 

#define f first
#define s second
#define mp make_pair
#define pb push_back
#define all(x) x.begin(), x.end()
#define kill(x) return cout<<x<<'\n', 0;
#define debug(x) cerr<<#x<<'='<<(x)<<endl;
#define fors(i,a,b) for(int i = a; i < b;i++) 
#define forsd(i,a,b) for(int i = a; i > b;i--) 
#define forpii(move) for(auto &&move : POSSIBLE_MOVES)
#define debug2(x, y) cerr<<"{"<<#x<<", "<<#y<<"} = {"<<(x)<<", "<<(y)<<"}"<<endl;
#define debugp(x) cerr<<#x<<"= {"<<(x.first)<<", "<<(x.second)<<"}"<<endl;
#define debugv(v) {cerr<<#v<<" : "<<endl;for (auto x:v) cerr<<x<<" "; cerr<<'\n';}
#define debug2dv(v) {cerr<<#v<<" : "<<endl;for (auto x:v){for (auto y:x) cerr<<y<<" ";cerr<<'\n';} cerr<<'\n';}
#define debugpv(v) {cerr<<#v<<" : "<<endl;for (auto x:v) cerr<<"= {"<<(x.first)<<", "<<(x.second)<<"}"<<endl;}
#define debug3pv(v) {cerr<<#v<<" : "<<endl;for (auto x:v) cerr<<"= {"<<(x.first.first)<<", "<<(x.first.second)<<" , "<<(x.second)<<"}"<<endl;}
#define endl '\n'

ll gcd(ll a , ll b){return a==0?b:gcd(b%a,a);}

const int MAXN = 1e9 + 10;
const int CIPHER = 5e3;
const int mod = 32;
const ll INF=1e10;
const int LOG=20;

// int  seg  [4*MAXN];
// int  lazy [4*MAXN];

void res_file(string name, vector<vector<int>> &data)
{
    ofstream res(name);
    fors(i, 0, 64)
    {
        for (int j = 24; j >= 0; j--)
            res << data[i][j];
        
        res << endl;
    }
    res.close();

}

int main(int argc, char* argv[])
{
    string name = argv[1];
    // string name = "0.in";
    vector<vector<int>> data(64, vector<int>(25));
    ifstream entry;
    string tempString;
    entry.open(name);
    int j=0;

    while (getline(entry,tempString,'\n'))
    {
        for (int i = 24; i >= 0; i--)
            data[j][24-i] = (tempString[i] - '0');
        j++;
    }
    entry.close();
    
    //col par
    vector<vector<int>> new_slice(64, vector<int>(25));
    fors(i, 0, 64)
    {
        fors(j, 0, 25)
        {
            bool prev=0, curr=0;
            fors(k, 0, 5)
            {
                int index = 5*k+(j%5 -1);
                int index_ = 5*k+(j%5 +1);
                curr ^= ((j%5 == 0)) ? 0 : data[i][index];
                prev ^= ((j%5 == 4)|(i == 0)) ? 0 : data[i-1][index_];
            }
            new_slice[i][j] = data[i][j] ^ curr ^ prev;
        }
    }
    data = new_slice;
    res_file(name.substr(0,name.size()-3)+"-colpar.out", data);

    //rotate
    int table[] = {21,8,41,45,15,56,14,18,2,61,28,27,0,1,62,55,20,36,44,6,25,39,3,10,43};
    fors(i, 1, 25)
    {
        vector<int> new_lane(64);
        fors(j, 0, 64)
            new_lane[j] = data[(unsigned(j-table[i]))%64][i];
        fors(j, 0, 64)
            data[j][i] = new_lane[j];
    }
    res_file(name.substr(0,name.size()-3)+"-rotate.out", data);

    //permutation
    int permut[] = {4,5,11,17,23,2,8,14,15,21,0,6,12,18,24,3,9,10,16,22,1,7,13,19,20};
    fors(i, 0, 64)
    {
        vector<int> new_slice(25);
        fors(j, 0, 25)
            new_slice[j] = data[i][permut[j]];
        
        data[i] = new_slice;
    }
    res_file(name.substr(0,name.size()-3)+"-permut.out", data);

    //revaluate
    fors(i, 0, 64)
    {
        vector<int> new_slice(25);
        fors(j, 0, 25)
        {
            bool noti = (j%5 == 4) ? 0 : ~(data[i][(j/5)+(j%5+1)]);
            bool andi = ((j%5 == 4)|(j%5 == 3)) ? 0 : ~(data[i][(j/5)+(j%5+2)]);
            new_slice[j] = data[i][j]^(noti&andi);
        }
        data[i] = new_slice;
    }
    res_file(name.substr(0,name.size()-3)+"-reval.out", data);

    //addRC
    string round[24];
    round[0] = "0000000000000001";
    round[1] = "000000008000808B";
    round[2] = "0000000000008082";
    round[3] = "800000000000008B";
    round[4] = "800000000000808A";
    round[5] = "8000000000008089";
    round[6] = "8000000080008000";
    round[7] = "8000000000008003";
    round[8] = "000000000000808B";
    round[9] = "8000000000008002";
    round[10] = "0000000080000001";
    round[11] = "8000000000000080";
    round[12] = "8000000080008081";
    round[13] = "000000000000800A";
    round[14] = "8000000000008009";
    round[15] = "800000008000000A";
    round[16] = "000000000000008A";
    round[17] = "8000000080008081";
    round[18] = "0000000000000088";
    round[19] = "8000000000008080";
    round[20] = "0000000080008009";
    round[21] = "0000000080000001";
    round[22] = "000000008000000A";
    round[23] = "8000000080008008";

    fors(j, 0, 24)
    {
        unsigned long long val;
        istringstream ost(round[j]);
        ost >> hex >> val;
        bitset<64>  biti(val);
        fors(i, 0, 64)
            data[i][0] ^= biti[i];
    }
    res_file(name.substr(0,name.size()-3)+"-addRC.out", data);

    res_file(name.substr(0,name.size()-3)+"-final.out", data);

    return 0;

}