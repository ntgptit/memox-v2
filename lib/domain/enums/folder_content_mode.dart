enum FolderContentMode {
  unlocked('unlocked'),
  subfolders('subfolders'),
  decks('decks');

  const FolderContentMode(this.storageValue);

  final String storageValue;
}
