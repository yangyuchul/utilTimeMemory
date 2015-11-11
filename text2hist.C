void text2hist(TString inFile, TString title="histogram", TString outname="hist.gif", int nBins=100, float minX=0, float maxX=50) {

	gStyle->SetOptStat(111100);
//	gStyle->SetOptStat(0);


	ifstream in;
	in.open(inFile);
	float value;
	int loop=0;
	std::vector<float> valueVec;
	float max=-1;
	float min=9999999;
	int maxEvent=-1;
	while(1) {
		in >> value;
		if(!in.good()) break;
		loop++;
		if(loop==1) continue;
//		cout << value << endl;
		valueVec.push_back(value);
		if(value > max) {
			max=value;
			maxEvent=loop;
		}
		if(value < min) min=value;
	}
	in.close();

	//TH1F* h1 = new TH1F("h1","h1",100,min,max*1.1);
	TH1F* h1 = new TH1F("h1",title,nBins,minX,maxX);
	h1->SetLineWidth(2);
	for(std::vector<float>::iterator it=valueVec.begin(); it!=valueVec.end(); it++) {
		h1->Fill(*it);
	}

	int entries = h1->GetEntries();
	float mean = h1->GetMean() ;
	float rms = h1->GetRMS() ;

	cout << "Entries " << h1->GetEntries() << endl;
	cout << "Mean " << h1->GetMean() << endl;
	cout << "RMS " << h1->GetRMS() << endl;
	cout << "Max " << max << " on evt " << maxEvent << endl;

	char temp1[100];
	char temp2[100];
	char temp3[100];
	char temp4[100];
	sprintf(temp1, "Entries: %d", entries);
	sprintf(temp2, "Time Mean: %.2f", mean);
	sprintf(temp3, "Time RMS: %.2f", rms);
	sprintf(temp4, "Time Max: %.2f on evt %d", max, maxEvent);
	
	TCanvas* c1 = new TCanvas();
	c1->SetLogy();
	h1->Draw();

	TLatex *t = new TLatex();
	t->SetNDC();
	t->SetTextAlign(22);
//	t->SetTextFont(63);
//	t->SetTextSizePixels(22);
//	t->DrawLatex(0.65,0.90,title);
	t->DrawLatex(0.65,0.85,temp1);
	t->DrawLatex(0.65,0.80,temp2);
	t->DrawLatex(0.65,0.75,temp3);
	t->DrawLatex(0.65,0.70,temp4);

	c1->Print(outname);
}
