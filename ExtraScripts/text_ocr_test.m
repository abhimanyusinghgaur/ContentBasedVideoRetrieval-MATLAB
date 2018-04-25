score_bar = imread('score_bar.jpg');
score_bar1 = imread('score_bar1.jpg');
score_bar2 = imread('score_bar2.jpg');
text = imread('text.jpg');
text1 = imread('text1.jpg');
text2 = imread('text2.jpg');
score = imread('score.jpg');
sl = imread('sl.jpg');


ocrResults = ocr(score_bar);
recognizedText = ocrResults.Text;
fprintf('score_bar: %s\n', recognizedText);

ocrResults = ocr(score_bar1);
recognizedText = ocrResults.Text;
fprintf('score_bar1: %s\n', recognizedText);

ocrResults = ocr(score_bar2);
recognizedText = ocrResults.Text;
fprintf('score_bar2: %s\n', recognizedText);

ocrResults = ocr(text);
recognizedText = ocrResults.Text;
fprintf('text: %s\n', recognizedText);

ocrResults = ocr(text1);
recognizedText = ocrResults.Text;
fprintf('text1: %s\n', recognizedText);

ocrResults = ocr(text2);
recognizedText = ocrResults.Text;
fprintf('text2: %s\n', recognizedText);

ocrResults = ocr(score);
recognizedText = ocrResults.Text;
fprintf('score: %s\n', recognizedText);

ocrResults = ocr(sl);
recognizedText = ocrResults.Text;
fprintf('sl: %s\n', recognizedText);