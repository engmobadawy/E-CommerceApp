import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5 // some dummy data
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = .red
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath)
            cell.backgroundColor = .blue
            return cell
        }
    }
}
